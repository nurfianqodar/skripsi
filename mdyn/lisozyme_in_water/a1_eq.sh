gmx grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -o nvt.tpr

gmx mdrun -deffnm nvt

gmx energy -f nvt.edr -o temperature.xvg

gmx grompp -f npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p topol.top -o npt.tpr

gmx mdrun -deffnm npt

gmx energy -f npt.edr -o pressure.xvg

gmx energy -f npt.edr -o density.xvg