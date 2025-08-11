#!/usr/bin/bash

# Hilangkan air
grep -v HOH 1AKI.pdb > out/1AKI_clean.pdb

# Ubah ke gromacs file
gmx pdb2gmx -f out/1AKI_clean.pdb -o out/1AKI_processed.gro -water spce

# Definisikan kotak/box
# Memusatkan protein di dalam kotak (-c), dan menempatkannya setidaknya 1,0 nm dari tepi kotak (-d 1.0).
# Jenis kotak didefinisikan sebagai kubus (-bt cubic). Jarak ke tepi kotak merupakan parameter penting.
# Karena kita akan menggunakan kondisi batas periodik, kita harus memenuhi konvensi citra minimum.
# Artinya, protein tidak boleh melihat citra periodiknya, jika tidak, gaya yang dihitung akan palsu.
# Menentukan jarak kotak zat terlarut sebesar 1,0 nm berarti terdapat setidaknya 2,0 nm di antara dua
# citra periodik protein. Jarak ini akan cukup untuk hampir semua skema pemotongan yang umum digunakan
# dalam simulasi.
gmx editconf -f out/1AKI_processed.gro -o out/1AKI_newbox.gro -c -d 1.0 -bt cubic


# Setelah kita sudah membuat kotak simulasi (box) dan menempatkan protein di dalamnya
# (dengan gmx editconf), langkah berikutnya adalah mengisi kotak tersebut dengan pelarut
# (biasanya air) agar simulasi molekuler bisa berlangsung dalam kondisi yang realistis.
# -cs spc216.gro
# Ini adalah file koordinat pelarut (solvent) standar yang sudah tersedia di instalasi GROMACS.
# spc216.gro berisi konfigurasi molekul air yang sudah “ekuilibrasi” dan siap digunakan sebagai
# pelarut. SPC adalah model air dengan 3 titik (3-point), artinya setiap molekul air
# direpresentasikan dengan tiga atom (2 H dan 1 O).
gmx solvate -cp out/1AKI_newbox.gro -cs spc216.gro -o out/1AKI_solv.gro -p topol.top


gmx grompp -f ions.mdp -c out/1AKI_solv.gro -p topol.top -o out/ions.tpr

gmx genion -s out/ions.tpr -o out/1AKI_solv_ions.gro -p topol.top -pname NA -nname CL -neutral

gmx grompp -f minim.mdp -c out/1AKI_solv_ions.gro -p topol.top -o out/em.tpr

gmx mdrun -v -deffnm out/em

gmx energy -f out/em.edr -o potential.xvg