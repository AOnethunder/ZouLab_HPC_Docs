### Software used in this Tutorial:

1. Amber 24 (18/20/22 is OK?)
2. PyMOL or VMD 1.9.3

### Introduction

Lipids are a crucial component of lipid bilayers and play an important role in many cell signaling and physiological processes. Condensed phase molecular dynamics software packages like **Amber**, Gromacs, NAMD, and CHARMM are now able to simulate a variety of biomolecules, including lipids.

### Amber Lipid force field

Currently, Amber includes Lipid11, Lipid14, Lipid17, and Lipid21 (the latest version) force field, modular lipid force of different Amber versions for tensionless lipid phospholipid simulations. The parameterization strategy of these force fields is consistent and compatible with the approach taken by other pairwise-additive Amber force fields. Therefore, they are, in principle, fully compatible with the other biomolecular force fields included in Amber.

The currently supported lipid "residues" are listed below as well as the validated lipid bilayers. For reference, we also list the previous lipids in GAFFlipid, Lipid14, and Lipid21.

**Lipid21 Residues**

|                      | Description               | LIPID21 Residue Name |
| -------------------- | ------------------------- | -------------------- |
| **Acyl chain** | Lauroyl (12:0)            | LAL                  |
|                      | Myristoyl (14:0)          | MY                   |
|                      | Palmitoyl (16:0)          | PA                   |
|                      | Sphingosine (16:1)        | SA                   |
|                      | Oleoyl (18:1 n-9)         | OL                   |
|                      | Stearoyl (18:0)           | ST                   |
|                      | Arachidonoyl (20:4)       | AR                   |
|                      | Docosahexaenoyl (22:6)    | DHA                  |
| **Head group** | Phosphatidylcholine       | PC                   |
|                      | Phosphatidylethanolamine  | PE                   |
|                      | Phosphatidylserine        | PS                   |
|                      | Phosphatidylglycerol (R-) | PGR                  |
|                      | Phosphatidylglycerol (S-) | PGS                  |
|                      | Phosphaditic acid         | PH-                  |
|                      | Sphingomyelin             | SPM                  |
| **Other**      | Cholesterol               | CHL                  |

**Lipid14 Residues**

|                      | Description              | LIPID14 Residue Name |
| -------------------- | ------------------------ | -------------------- |
| **Acyl Chain** | Lauroyl (12:0)           | LA                   |
|                      | Myristoyl (14:0)         | MY                   |
|                      | Palmitoyl (16:0)         | PA                   |
|                      | Stearoyl (18:0)          | ST                   |
|                      | Oleoyl (18:1 n-9)        | OL                   |
| **Head Group** | Phosphatidylcholine      | PC                   |
|                      | Phosphatidylethanolamine | PE                   |

**Lipid11 Residues**

|                      | Description                | LIPID11 Residue Name |
| -------------------- | -------------------------- | -------------------- |
| **Acyl Chain** | Palmitoyl (16:0)           | PA                   |
|                      | Stearoyl (18:0)            | ST                   |
|                      | Oleoyl (18:1 n-9)          | OL                   |
|                      | Linoleoyl (18:2 n-6)       | LEO                  |
|                      | Linolenoyl (18:3 n-3)      | LEN                  |
|                      | Arachidonoyl (20:4 n-6)    | AR                   |
|                      | Docosahexanoyl (22:6 n-3)  | DHA                  |
| **Head Group** | Phosphatidylcholine        | PC                   |
|                      | Phosphatidylethanolamine   | PE                   |
|                      | Phosphatidylserine         | PS                   |
|                      | Phosphatidic acid (PHO4 -) | PH-                  |
|                      | Phosphatidic acid (PO4 2-) | P2-                  |
|                      | R-phosphatidylglycerol     | PGR                  |
|                      | S-phosphatidylglycerol     | PGS                  |
| **Other**      | Phosphatidylinositol       | PI                   |
|                      | Cholesterol                | CHL                  |

**GAFFlipid Molecules**

| Name                                                  | GAFFlipid Molecule Name |
| ----------------------------------------------------- | ----------------------- |
| 1,2-dilauroyl-sn-glycero-3-phosphocholine             | DLPC                    |
| 1,2-dimyristoyl-sn-glycero-3-phosphocholine           | DMPC                    |
| 1,2-dioleoyl-sn-glycero-3-phosphocholine              | DOPC                    |
| 1,2-dipalmitoyl-sn-glycero-3-phosphocholine           | DPPC                    |
| 1-palmitoyl-2-oleoyl-sn-glycero-3-phosphocholine      | POPC                    |
| 1-palmitoyl-2-oleoyl-sn-glycero-3-phosphoethanolamine | POPE                    |

**Amber LIPID force field residues' PDB format for LEaP**

| Lipid 1           | sn-1 tial residue  |
| :---------------- | ------------------ |
|                   | head group residue |
|                   | sn-2 tail residue  |
|                   | TER card           |
| **Lipid 2** | sn-1 tail residue  |
|                   | head group reisdue |
|                   | sn-2 tail residue  |
|                   | TER card           |
| ...               | ...                |

### **Options for building a membrane structure**

In order to simulate a lipid bilayer, it is necessary to first obtain a starting structure in PDB format that can be processed by Amber's LEaP program. There are several accessible options for building a lipid structure:

[**CHARMM-GUI Lipid Builder**](http://www.charmm-gui.org/?doc=input/membrane.bilayer)

A simple, internet based solution to generating **lipid bilayer** structures as well as **membrane-bound protein structures**.

[**VMD Membrane Builder plugin**](http://www.ks.uiuc.edu/Research/vmd/plugins/membrane/)

A plugin is available for the Visual Molecular Dynamics (VMD) program that can currently build POPC and POPE bilayer systems. A tutorial explaining how to build lipid bilayers as well as insert membrane-bound proteins is available on the VMD web site.

**Amber "packmol-memgen" tool**

A simple-to-use, generalized workflow for automated building of membrane-protein–lipid-bilayer systems based on open-source tools including Packmol, memembed, pdbremix, and AmberTools. It is currently included in the AmberTools.
