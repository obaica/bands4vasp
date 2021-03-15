# bands4vasp

***

## What is bands4vasp?

***

The **bands4vasp** post-processing package is exclusively build for the analysis and visualisation of bandstructure- and especially unfolding calculations from VASP.
It uses the energy values, the k-space coordinates and optionally the orbital- and blochcharacters from the **PROCAR**, **PROCAR.prim** or **PRJCAR** files.
Also a lattice is needed to project the k-points on the Fermi level and calculate the Fermi vectors.
The reciprocal lattice of the primitive cell, given in the **PRJCAR** file, is the prefered lattice.
If the **PRJCAR** file is not present, the lattice given in the **POSCAR** file will be taken.
For a correct bandstructure of an unfolding calculation it is necesarry to have at least one **PRJCAR** file in your dataset.
All energy values will be represented with respect to the fermi-energy, where the fermi-energy is taken from the **OUTCAR** file of the self-consistent calculation from the structure or can be entered by the user.
**bands4vasp** calculates the roots at the fermi-level for all kind of bands. All this information are visualized in several plots.
With a dataset of line calculations in a surface of the Brillouin zone, one can **bands4vasp** let calculate the fermiroots and than let it project onto that surface.
**bands4vasp** is written in _FORTRAN_, it uses _Gnuplot_ for the visualisation and a _Bash-environment_ which brings all together.

***

## In- and output files

***


### VASP-files (input)

---


There are 3 typs of files bands4vasp can handle:

* The **PRJCAR** file is only present if one had activate the unfolding procedure in VASP and therefore every energy value can be associated with a so called Bloch-character. Orbital characters are absent in the PRJCAR file and will be as well for all the derived values and plots form this files.

* The **PROCAR** file comes from calculations with LORBIT (see vaspwiki) and contains all information to the orbitals, the so-called orbital characters, but there are no information of the Bloch-characters.

* The **PROCAR.prim** file containes both, the Bloch- and the orbital character.

### bands4vasp output files

---

bands4VASP provides a lot of different information, which it derives from the VASP files.

#### Datafiles:

* _FERMIROOTS_ contains all information of the evaluated Fermi vectors.
* _FERMISURFACE_ contains all information of the evaluated fermisurface.
* _FERMISURFACE.spec_ contains all information of the evaluated fermisurface spectral function.

#### Plots

* _Bandsturcture*_ shows the unfiltered bands inbetween the energy interval [-EDELTA1;EDELTA1].
* _EBSbloch*_ shows the unfiltered bands inbetween the energy interval [-EDELTA1;EDELTA1] with there according Bloch character.
* _EBSorbit*_ shows the unfiltered bands inbetween the energy interval [-EDELTA1;EDELTA1] with there according orbital character and if present a variable pointsize proportional to the Bloch character.
* _.spec._ shows the spectral function inbetween the energy interval [-EDELTA1;EDELTA1] according to the Bloch character.
* _Fermisurface.specfun_ shows the Fermisurface derived from the spectral function according to the Bloch character.
* _Bandindexplot_ shows the Bandstructure according to the bandindex occuring in the VASP files.
* _Fermisurface_bloch_ shows the derived fermisurface with the calculated avaraged Bloch characters.
* _Fermisurface_orbital_ shows the derived fermisurface with the calculated avaraged orbital character.


_*These plots have also a fine version inbetween the energy interval [-EDELTA2;EDELTA2], which indicates the extension .fine._


### INPAR - The bands4vasp input file

Bands4vasp needs a file for all input parameters. This file is called **INPAR**.
If you run bands4vasp and no INPAR file is present in the current directory, bands4vasp will copy the default INPAR file to your directory.
Some parameters have only an effect, if a specific VASP filetype was choosen, because not every information is stored in all of the 3 files.

#### General control parameters

* **EDELTA1** - energy interval (y-axis) [-EDELTA1;EDELTA1] for the unfiltered plots EBSbloch, EBSorbit, EBSbloch.spec and Bandindexplot.
* **EDELTA2** - energy interval (y-axis) [-EDELTA2;EDELTA2] for the filtered plots.
* **EDIF**  - Energy diffusion from the unfolding calculation. The energy interval in between it compresses the points to one avaraged point.
* **BAVERAGE** - If this is set to .TRUE. the weighted average of the blochcharacter is calculated, else the values will summed up.
* **OAVERAGE** - If this is set to .TRUE. the weighted average of the orbitalcharacter is calculated, else the values were summed up.
