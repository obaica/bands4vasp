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

* **ROOTSCALC** - If set to .FALSE. no Fermi vectors will be calculated.
* **SKIPKPOINT** - If there is one integer number n, bands4vasp ignores the first n k-points of every file. If 2 integer seperated by a minus n-m, the k-points n up to m will be ignored. For 0 no k-point is skipped.
* **SELECTION** Select a specific Ion and the associated orbital characters, in order of appearence in PROCAR[.prim] file. If 2 integer seperated by a minus n-m are given only the orbital characters of ion n up to m is taken.
* **EDELTA1** - energy interval (y-axis) [-EDELTA1;EDELTA1] for the unfiltered plots EBSbloch, EBSorbit, EBSbloch.spec and Bandindexplot.
* **EDELTA2** - energy interval (y-axis) [-EDELTA2;EDELTA2] for the filtered plots.
* **EDIF**  - Energy diffusion from the unfolding calculation. The energy interval in between it compresses the points to one avaraged point.
* **BAVERAGE** - If this is set to .TRUE. the weighted average of the Blochcharacter is calculated, else the values will summed up.
* **OAVERAGE** - If this is set to .TRUE. the weighted average of the orbital character is calculated, else the values were summed up.
* **EGAP** - This has to be a real value and describes the maximal energy difference for two points to belong to the same effective band.
* **THRESHOLD** - Sets the minimal Bloch character value for which a point will be accepted. One can also set it to a negative value, than every point of the original file(s) is taken.
* **DBLOCH** - This has to be a real value and describes the maximal Bloch character difference for two points to belong to the same effective band.
* **GRADIENTD** - Gives the maximal gradient deviation.
* **NPOINTS** - Number of points which will be take account to the fermiroots calculation for each side.
* **LPOLY** - If set to .TRUE. a polynomial interpolation with the degree 2*NPOINTS will be used for the fermiroots calculation.
If set to $.FALSE.$ a linear regression will be used for the fermiroots calcualtion.
* **REGULARPREC** - This has to be a real value and sets the accuracy for the Regular falsi method, which is used to calculate the k-distance of the fermiroots.
* **PLOTORB** - Sets the Orbital, which is shown in the EBSorbit plots.
It has to be an integer which corresponds to the order of the orbitals in the PROCAR[.prim] file. If PLOTORB is set to 0 all orbitalplots are printed in EBSorbit_ALL.
* **ODISTINCT** - It has to be a real value and describes the maximal orbital character difference for two points to belong to the same effective band.
* **BNDDIFF** - If this is set to .TRUE. the algorythm takes also points with different Bandindex for the fermiroots calculation.
For unfolding data it is recommend to set it to .TRUE. and for no-folding data set it to .FALSE..
* **KAPPANORM** - If this is set to .TRUE. the Bloch character for each band and K-POINT (SC) get normed respectively.


#### Fermisurface

The parameters in the following section are only considered if a fermisurface calculation is done, by passing the option _--fermi_.

* **SYMPOINT1/SYMPOINT2** - These are the symmetry points for the resulting fermisurface* plots. If both are commented out (\#) the fermisurface* plots will only show the calculated roots projected on the surface in were the calculations were done. If the SYMPOINT1 set to a 3d-vector, where the values have to be seperated by one space ("SYMPOINT1 = 0.0 0.0 0.0"), the calculated values will be copied to the rotaded positions at rotation angles 90°, 180° and 270°.
If SYMPOINT2 is also set to a vector, the calculated roots will axial reflected with the mirror axis defined by SYMPOINT1 and SYMPOINT2.
* **SYMREC** - If this is set to .TRUE. the coordinates of the symmetry points SYMPOINT1 and SYMPOINT2 from above, are interpreted as reciprocal coordinates. If it is set to .FALSE. the coordinates are interpreted as cartesian.
* **FGRID** - An equidistant grid is produced for the fermisurface plot. FGRID can set to the number of meshes. If set to 0 no grid will be shown in the plot.

#### Spectral function

* **SPECFUN**  - If this is set to .TRUE. the spectral function plot is activated.
* **SIGMA** - This value defines the smearing of the deltafunction in the spectral function.
* **SPECDELTA** - The smaller this real value (in eV) is, the higher is the number of energy points per k-point for which the spectral function is evaluated, which results in a higher resolution, more computing capacity and larger *.specfun* files.
* **SLIMSPEC** - If this is set to .TRUE. it will only write data where the Bloch character is larger than 0. This can save memory, because of smaller *.specfun* files. Otherwise every value from every energy step will be written in the *.specfun* files.

#### Plot specific options

* **MAKEPLOTS** - If set to .TRUE. bands4vasp produces the plots, if set to .FALSE. no plots will be produced.
* **FILEFORMAT** - One can chose the format of the file from {pdf, png, epslatex, cairolatex, eps (default)}.
* **PLOTSIZE** - One can give an explicite size 'x, y' for the plots. The coordinates have to be seperated by a ','. Values between 0 and 1 gives the ratio, respectively. Values greater than 1 are interpreted as pixels. One can also add units as 'cm', but in general the possible unit depends on the format (see gnuplot documentation). If commented (\#) gnuplot sets a default size (recommended).
* **BANDINDEXPLOT** - If this is set to .TRUE. the Bandindexplot is created.
* **LEAVEPLOTDATA** - If this is set to .TRUE., bands4vasp leaves all needed files to generate the plots:
- The Gnuplot file 'autognuplotEBS.gnu', which creates all plots.
- The data files 'autoplotdata$$$', where the dollar signs are placeholder for numbers.

#### Visual parameters

* **PATHPOINTS** - Here one can write the letters for the lattice symmetry points in the Brillouin zone. Especially for multipath calculations this can be a great benefit. A '/' infront of the letter prints the greek version of the letter. If this option is commented (\#). the  k-distance will be shown instead.
* **LFITPOINTS** - If this is set to .TRUE. the fitpoints which were used to calculate the fermiroots are shown in the plots.
* **LLINES** - If this is set to .TRUE. the graph, derived from the fitpoints ether with linear regression or polynomial interpolation, will be shown in the plots.
* **LROOTS** - If this is set to .TRUE. the fermiroots will be shown in the plots and if there are no roots the energygap will be shown.
* **PSFAC** - With that factor one can change the pointssize in the plots => pointsize=original_pointsize * PSFAC
* **BCOLOURS** - These have to be 2 colors seperated by space, the first one is the color for Bloch character equals to zero and the second one is the color for the maximal value. For a list of all accesable colornames open the terminal and enter: _gnuplot -e 'show palette colornames'_
* **OCOLOURS** - This is the same as for BCOLOURS above, with the different that this colors are for the orbital plots.
* **BACKCOLOUR** - This is the background color of the plots.

## Usage

Usage: bands4vasp [OPTION] ... [file]<br/>
Options:<br/>
  --help                  Display this information.<br/>
  --info                  The same as --help.<br/>
  --inpar                 copy the default INPAR file to your current directory.<br/>
  --fermi [file]          make a fermisurface calculation.<br/>
  --pre-lines $1 $2       prepare a multi directory with the k-points in<br/>
                          KPOINTS file after the flag '#makepath'.<br/>
                          $1 = directory for the prepared VASP files<br/>
                          $2 = name for the multidirectory<br/>
  --pre-circle $1 $2 $3   prepare a multi directory with a circle given in<br/>
                          the KPOINTS file after the flag '#makepath'.<br/>
                          There should be 3 points:<br/>
                          1.The first point is the center of the circle<br/>
                          2.The second point is the start point<br/>
                          3.The third point is the end point<br/>
                          It calculates the points along the circle in<br/>
                          a mathematically positv sense.<br/>
                          The calculation will be done as a line from<br/>
                          the given center to each calculated point.<br/>
                          $1 = directory for the prepared VASP files<br/>
                          $2 = number of equidistant points on the circle<br/>
                          $3 = name for the multidirectory<br/>
  --pre-surface $1 $2 $3  prepare a multi directory with a surface of lines given<br/>
                          in the KPOINTS file after the flag '#makepath'.<br/>
                          There should be 3 points:<br/>
                          1.The first corner of the surface where the calculation starts<br/>
                          2.The second corner of the surface, which defines with the first<br/>
                            given point the direction of the line calculations<br/>
                          3.The third corner of the surface, which defines with the 2nd<br/>
                            corner the direction of the translation of the lines<br/>
                          $1 = directory for the prepared VASP files<br/>
                          $2 = number of equidistant lines on the surface<br/>
                          $3 = name for the multidirectory<br/>


Passing files:<br/>
 There are 3 ways to pass files to band4vasp<br/>

 -Single path:   If you only have one path of calculation data you can go eather in the directory<br/>
                 and just execute band4VASP or you can pass the directory in which the data are stored.<br/>
                 => bands4vasp "directory"<br/>

 -Multi path:   If you have more than one path (e.g. Fermisurface) you should named it equaly dispite<br/>
                a number in the name, or simply use the --pre options of band4VASP. You can start<br/>
                the multipath calculation by passing a %-sign as a placeholder for numbers. If we have:<br/>
                "1fermi 2fermi 3fermi 4fermi 5fermi 6fermi 7fermi ..." we can simply enter:<br/>
                bands4vasp %fermi<br/>

 -Fermisurface: For a Fermisurface you pass the multi path structure with a %-sign as discribed befor.<br/>
                You only add the option --fermi to the command:<br/>
                bands4vasp --fermi %fermi<br/>
