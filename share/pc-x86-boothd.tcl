#!/usr/bin/env tclsh

#
# Generate a PC-x86 bootable hard disk.
#
# Copyright (C) 2020, 2021, 2022 Gabriele Galeotti
#
# This work is licensed under the terms of the MIT License.
# Please consult the LICENSE.txt file located in the top-level directory.
#

#
# Arguments:
# $1 = input binary file
# $2 = BOOTSEGMENT (CS value)
# $3 = ID of physical device or virtual device filename (prefixed with "+")
#
# Environment variables:
# SWEETADA_PATH
# LIBUTILS_DIRECTORY
# SHARE_DIRECTORY
# TOOLCHAIN_CC
# TOOLCHAIN_LD
# TOOLCHAIN_OBJDUMP
#

#
# bootsector.S differences from standard floppy disk bootrecord:
# - physical disk number = 0x80
# - nsectorshi, nsectorslo, spt, heads are configurable
# - no floppy disk motor shutdown
#

################################################################################
# Script initialization.                                                       #
#                                                                              #
################################################################################

set SCRIPT_FILENAME [file tail $argv0]

################################################################################
# ls2chs                                                                       #
#                                                                              #
# Convert a logical sector value to CHS format.                                #
# CHS layout in MBR: [0]=HEAD, [1]=SECTOR|CYLINDERH, [3]=CYLINDERL             #
################################################################################
proc ls2chs {sectorn cyl hpc spt} {
    set chs {}
    lappend chs [expr ($sectorn / $spt) % $hpc]
    set c [expr ($sectorn / ($spt * $hpc)) % $cyl]
    set cl [expr $c % 2**8]
    set ch [expr $c / 2**8]
    lappend chs [expr (($sectorn % $spt) + 1) + ($ch * 2**6)]
    lappend chs $cl
    return $chs
}

################################################################################
# write_partition                                                              #
#                                                                              #
################################################################################
# manually create an MS-DOS partition
# -----------------------------------
# 1st partition descriptor: offset 0x1BE = 446
# 80          = boot indicator                        = bootable
# 00 01 01    = starting encoded CHS, INT 0x13 format = H:0x00 S:0x01 C:0x01 = second cylinder, first head, first sector
# ??          = partition type                        =
# 03 11 1F    = ending encoded CHS, INT 0x13 format   = H:0x03 S:0x11 C:0x1F = last cylinder, last head, last sector
# 44 00 00 00 = starting sector (0-based, LBA)        = 0x00000044 = 4 * 17 = HPC * SPT
# 3C 08 00 00 = partition size in sectors             = 0x0000083C = (32 - 1) * 4 * 17 = (CYL - 1) * HPC * SPT
proc write_partition {f sector_start sector_size} {
    global CYL
    global HPC
    global SPT
    set fp [open $f "a+"]
    seek $fp 0x1BE
    # bootable flag
    puts -nonewline $fp [binary format c1 0x80]
    # CHS start
    puts -nonewline $fp [binary format c3 [ls2chs $sector_start $CYL $HPC $SPT]]
    # partition type (FAT32 CHS mode)
    puts -nonewline $fp [binary format c1 0x0B]
    # CHS end; ending sector, not the following one
    puts -nonewline $fp [binary format c3 [ls2chs [expr $sector_start + $sector_size - 1] $CYL $HPC $SPT]]
    # LBA sector start
    puts -nonewline $fp [binary format c4 [u32_to_lebytes $sector_start]]
    # LBA size in sectors
    puts -nonewline $fp [binary format c4 [u32_to_lebytes $sector_size]]
    close $fp
}

################################################################################
# Main loop.                                                                   #
#                                                                              #
################################################################################

source [file join $::env(SWEETADA_PATH) $::env(LIBUTILS_DIRECTORY) library.tcl]

#
# Basic input parameters check.
#
if {[llength $argv] < 3} {
    puts stderr "$SCRIPT_FILENAME: *** Error: invalid number of arguments."
    exit 1
}

set kernel_filename [lindex $argv 0]
set bootsegment [lindex $argv 1]
set device_filename [lindex $argv 2]

puts "$SCRIPT_FILENAME: creating hard disk ..."

set BPS 512
set CYL 820
set HPC 6
set SPT 17

set SECTORS_PER_CYLINDER [expr $HPC * $SPT]
set SECTOR_COUNT [expr $CYL * $SECTORS_PER_CYLINDER]

if {[string index $device_filename 0] eq "+"} {
    set device_type FILE
    set device_filename [string trimleft $device_filename "+"]
    set fp [open $device_filename "w"]
    seek $fp [expr $SECTOR_COUNT * $BPS - 1]
    puts -nonewline $fp [binary format c1 0]
    close $fp
} else {
    set device_type DEVICE
    while {$device_filename eq ""} {
        puts "No device was specified."
        puts -nonewline "Enter device (e.g., /dev/sdf, <ENTER> to retry): "
        flush stdout
        gets stdin device_filename
    }
}

# partiton starts on cylinder boundary (1st full cylinder reserved for MBR)
set PARTITION_SECTOR_START $SECTORS_PER_CYLINDER
set PARTITION_SECTORS_SIZE [expr $SECTOR_COUNT - $SECTORS_PER_CYLINDER]
puts "partition sector start: $PARTITION_SECTOR_START"
puts "partition sector size:  $PARTITION_SECTORS_SIZE"

# build MBR (MS-DOS 6.22)
eval exec $::env(TOOLCHAIN_CC)                                    \
  -o mbr.o                                                        \
  -c                                                              \
  [file join $::env(SWEETADA_PATH) $::env(SHARE_DIRECTORY) mbr.S]
eval exec $::env(TOOLCHAIN_LD) -o mbr.bin -Ttext=0 --oformat=binary mbr.o
eval exec $::env(TOOLCHAIN_OBJDUMP) -m i8086 -D -M i8086 -b binary mbr.bin > mbr.lst

# write MBR @ CHS(0,0,1)
puts "$SCRIPT_FILENAME: creating MBR ..."
set fp [open "mbr.bin" "r"]
fconfigure $fp -translation binary
set mbr [read $fp]
close $fp
set fp [open $device_filename "a+"]
fconfigure $fp -translation binary
seek $fp [expr 0 * $BPS]
puts -nonewline $fp $mbr
close $fp

# write partition
puts "$SCRIPT_FILENAME: creating partition ..."
write_partition $device_filename $PARTITION_SECTOR_START $PARTITION_SECTORS_SIZE

# build bootrecord
set kernel_size [file size $kernel_filename]
# handle large partitions
if {$PARTITION_SECTORS_SIZE > 65535} {
    set PARTITION_SECTORS_SSIZE 0
    set PARTITION_SECTORS_LSIZE $PARTITION_SECTORS_SIZE
} else {
    set PARTITION_SECTORS_SSIZE $PARTITION_SECTORS_SIZE
    set PARTITION_SECTORS_LSIZE 0
}
set NSECTORS [expr ($kernel_size + $BPS - 1) / $BPS]
puts [format "kernel sector count: %d (0x%X)" $NSECTORS $NSECTORS]
eval exec $::env(TOOLCHAIN_CC)                                           \
  -o bootsector.o                                                        \
  -c                                                                     \
  -DCYLINDERS=$CYL                                                       \
  -DHEADS=$HPC                                                           \
  -DSPT=$SPT                                                             \
  -DPARTITION_SECTOR_START=$PARTITION_SECTOR_START                       \
  -DPARTITION_SECTORS_SSIZE=$PARTITION_SECTORS_SSIZE                     \
  -DPARTITION_SECTORS_LSIZE=$PARTITION_SECTORS_LSIZE                     \
  -DNSECTORS=$NSECTORS                                                   \
  -DBOOTSEGMENT=$bootsegment                                             \
  -DDELAY                                                                \
  [file join $::env(SWEETADA_PATH) $::env(SHARE_DIRECTORY) bootsector.S]
eval exec $::env(TOOLCHAIN_LD) -o bootsector.bin -Ttext=0 --oformat=binary bootsector.o
eval exec $::env(TOOLCHAIN_OBJDUMP) -m i8086 -D -M i8086 -b binary bootsector.bin > bootsector.lst

# write bootrecord @ CHS(1,0,1)
puts "$SCRIPT_FILENAME: creating bootrecord ..."
set fp [open "bootsector.bin" "r"]
fconfigure $fp -translation binary
set bootrecord [read $fp]
close $fp
set fp [open $device_filename "a+"]
fconfigure $fp -translation binary
seek $fp [expr $SECTORS_PER_CYLINDER * $BPS]
puts -nonewline $fp $bootrecord
close $fp

# write kernel @ CHS(1,0,2)
puts "$SCRIPT_FILENAME: writing input binary file ..."
set fp [open $kernel_filename "r"]
fconfigure $fp -translation binary
set kernel [read $fp]
close $fp
set fp [open $device_filename "a+"]
fconfigure $fp -translation binary
seek $fp [expr ($SECTORS_PER_CYLINDER + 1) * $BPS]
puts -nonewline $fp $kernel
close $fp

# flush disk buffers
exec sync
exec sync

exit 0

