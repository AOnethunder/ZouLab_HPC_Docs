# 安装纪录

## 0. 以下软件安装路径全部默认为在主账户（zouyike）家目录的上一级目录的*share/software*目录下

如果是**PI 2.0**，这个路径为 `/lustre/home/acct-zouyike/share/software`

如果是**思源一号**，这个路径为 `/dssg/home/acct-zouyike/share/software`

如果要在相应集群（PI 2.0/思源一号）安装一个所有子账户都要使用的软件，只能安装在上面相应的路径下才能使大家都有权限使用。

**0.1 建议在群上使用Module包管理安装的软件，这样不会使得.bashrc文件变得混乱：**

首先在默认安装路径下建立一个存放module files的文件夹，切换到默认安装路径下：

```bash
# 思源一号
cd /dssg/home/acct-zouyike/share/software
# 如果是PI 2.0，运行下一行命令
#cd /lustre/home/acct-zouyike/share/software

#在默认路径下建立modulefiles文件夹
mkdir modulefiles

#在.bashrc文件中加入如下一行
module use /dssg/home/acct-zouyike/share/software/modulefiles
```

所有准备工作已经做好！

## 1. Gaussian（高斯）:压缩包 E6B-113X_AVX2.tbz

1.1 假设在默认安装路径下已经有安装包，在默认安装路径下解压压缩包

```bash
# 切换到默认安装路径，思源一号：
cd /dssg/home/acct-zouyike/share/software
# 如果是PI 2.0，运行下一行命令
#cd /lustre/home/acct-zouyike/share/software

# 压缩包为g16 A03版本，新建一个文件夹
mkdir g16.A03
# 解压文件到g16.A03/中
tar jxvf E6B-113X_AVX2.tbz -C g16.A03
```

1.2 准备Gaussian环境的module files文件

```bash
# 为g16建立 modulefiles
mkdir -p modulefiles/g16

cat >modulefiles/g16/A03<<EOF
#%Module

set red "\033\[1;31m"
set green "\033\[1;32m"
set reset "\033\[0m"

setenv g16root "/dssg/home/acct-zouyike/share/software/g16.A03"
puts stderr "g16root of \${red}g16.A03\$reset is set"
puts stderr "\t* add \$green source \\\$g16root/g16/bsd/g16.profile \$reset to you job scripts"

conflict g16
EOF
```

安装完成，下面是简单提交任务测试。

1.3 准备好高斯输入文件，假设有高斯计算任务(文件名为 test.com)。

1.4 使用辅助脚本生成高斯任务作业脚本并提交到slurm作业管理系统

```bash
genslm_g16 test.com  #将会生成作业脚本文件slm_g16_test.sh
sbatch slm_g16_test.sh  #提交高斯作业
```

1.5 结束后将会得到计算结果文件（test.log）及一些其他的输出文件。

## 2. RoseTTAFold-All-Atom

2.1 进入software/文件夹并安装Mamba

```bash
cd software/
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
bash Mambaforge-$(uname)-$(uname -m).sh  # install to the location "/lustre/home/acct-zouyike/zouyike/software/mambaforge"
#rm Mambaforge-$(uname)-$(uname -m).sh  # (optionally) remove installer after using it
source ~/.bashrc  # alternatively, one can restart their shell session to achieve the same result
```

2.2 克隆软件包（RoseTTAFold-All-Atom）

```bash
git clone https://github.com/baker-laboratory/RoseTTAFold-All-Atom.git
cd RoseTTAFold-All-Atom
```

2.3 创建Mamba的环境

```bash
module load cuda/11.8.0
CONDA_OVERRIDE_CUDA="11.8" mamba env create -f environment.yaml #注意这一步跟官方安装教程不一样
conda activate RFAA  # NOTE: one still needs to use `conda` to (de)activate environments

cd rf2aa/SE3Transformer/
pip3 install --no-cache-dir -r requirements.txt
python3 setup.py install
cd ../../
```

2.4 下载并配置signalp6（[https://services.healthtech.dtu.dk/services/SignalP-6.0/](https://services.healthtech.dtu.dk/services/SignalP-6.0/) 下载需要用学校邮箱注册）

```bash
# NOTE: (current) version 6.0h is used in this example, which was downloaded to the current working directory using `wget`
signalp6-register signalp-6.0h.fast.tar.gz

# NOTE: once registration is complete, one must rename the "distilled" model weights
mv $CONDA_PREFIX/lib/python3.10/site-packages/signalp/model_weights/distilled_model_signalp6.pt $CONDA_PREFIX/lib/python3.10/site-packages/signalp/model_weights/ensemble_model_signalp6.pt

```

2.5 安装输入准备依赖项

```bash
bash install_dependencies.sh
```

2.6 下载模型 (已下载完成)

```bash
wget http://files.ipd.uw.edu/pub/RF-All-Atom/weights/RFAA_paper_weights.pt
```

2.7 下载用于MSA和模板生成的序列数据库

```bash
# uniref30 [46G]
wget http://wwwuser.gwdg.de/~compbiol/uniclust/2020_06/UniRef30_2020_06_hhsuite.tar.gz #本地下载
mkdir -p UniRef30_2020_06
tar xfz UniRef30_2020_06_hhsuite.tar.gz -C ./UniRef30_2020_06

# BFD [272G]
wget https://bfd.mmseqs.com/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz #本地下载
mkdir -p bfd
tar xfz bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz -C ./bfd

# structure templates (including *_a3m.ffdata, *_a3m.ffindex)
wget https://files.ipd.uw.edu/pub/RoseTTAFold/pdb100_2021Mar03.tar.gz #本地下载
tar xfz pdb100_2021Mar03.tar.gz
```

## 2. XTB

1. 下载xtb最新版本（当前为6.7.0）

```bash
mkdir xtb
cd xtb
git clone https://github.com/grimme-lab/xtb.git
module load gcc/11.2.0   #加载gcc 11.2.0版本，因为用gfortran 8.5编译会报错！
## 在Pi 2.0上gcc8.5.0编译git clone下载的包报错！但是编译直接下载源码包成功。比如通过下面的方式下载：
## wet https://github.com/grimme-lab/xtb/releases/download/v6.7.0/xtb-6.7.0-source.tar.xz
```

2. 建立安装目录

```bash
mkdir xtb-amber24
cd xtb

#通过压缩包的方式编译
# tar Jxvf xtb-6.7.0-source.tar.xz #解压后会有一个文件夹“xtb-6.7.0/”，如果使用git clone 下载的，不用解压就有文件夹“xtb”
# mkdir xtb-amber24  #新建xtb的安装路径
# cd xtb-6.7.0     #xtb-6.7.0 的源代码
```

3. 运行cmake设置

   ```bash
   #把cmake命令放到上一级目录的一个文件中，这样每次报错重新安装不用再输入这么长的命令！
   #PS：运行xtb的cmkae命令极易报错！因为它需要从github上下载其他代码
   cat > ../run_xtb_amber_install_cmake.sh <<EOF
   #!/bin/bash
   export XTBHOME=/lustre/home/acct-zouyike/luoshenggan/software/xtb/xtb-amber24
   export FC=gfortran
   export CC=gcc
   cmake -B_build \
   	-DCMAKE_BUILD_TYPE=RelWithDebInfo \
   	-DBUILD_SHARED_LIBS=TRUE \
   	-DINSTALL_MODULES=TRUE \
   	-DCMAKE_EXE_LINKER_FLAGS="-lm" \
   	-DBLAS_LIBRARIES="-lopenblas" \
   	-DLAPACK_LIBRARIES="-lopenblas" \
   	-DCMAKE_INSTALL_PREFIX=${XTBHOME}
   EOF

   #运行cmake进行设置（如果报错，请从第1，2步和这一步重来！）
   ./../run_xtb_amber_install_cmake.sh

   ```
4. 编译和安装

   ```bash
   make -C _build  #在这之前先确保libopenblas.so能够被找到 运行 module load openblas/0.3.23-gcc-8.5.0 加载openblas
   make -C _build install  #安装完成后应该在安装目录下有/lib64/libxtb.so, include/xtb.h, inclue/xtb_type_solvation.mod

   ```
5. 准备一个modulefile文件用于加载xtb环境，最好把它放到MODULEPATH中的路径中，方便用module load加载环境。它包含以下内容：

```bash
#%Module
set prefix /lustre/home/acct-zouyike/luoshenggan/software/xtb/xtb-amber24

setenv XTB_ROOT $prefix
setenv OMP_NUM_THREADS 40
setenv MKL_NUM_THREADS 40
setenv OMP_STACKSIZE 3000m

module-whatis "Semiempirical Extended Tight-Binding Program Package"

prepend-path LD_LIBRARY_PATH $prefix/lib64
prepend-path XTBPATH $prefix/share/xtb
prepend-path PATH $prefix/bin
prepend-path MANPATH $prefix/share/man
prepend-path PKG_CONFIG_PATH $prefix/lib64/pkgconfig

# Only allow to load one instance of xtb
conflict xtb


```

## 2. DFTB+

1. 下载DFTB+

```bash
mkdir dftbplus
cd dftbplus
git clone https://github.com/dftbplus/dftbplus.git
module load gcc/11.2.0
mkdir dftbplus-amber/
cd dftbplus
```

2. 运行cmake设置

```bash
module load openblas/0.3.23-gcc-8.5.0 #加载openblas
# 把cmake命令放到上一级目录的一个文件中，这样每次报错重新安装不用再输入这么长的命令！
cat > ../run_install_dftbplus_amber_cmake.sh <<EOF
#!/bin/bash

export DFTBPLUSHOME=/lustre/home/acct-zouyike/luoshenggan/software/dftbplus/dftbplus-amber
export FC=gfortran
export CC=gcc
module load xtb/6.7.0_amber24
cmake -DCMAKE_INSTALL_PREFIX=${DFTBPLUSHOME} \
	-DHYBRID_CONFIG_METHODS="Find" \
	-DCMAKE_PREFIX_PATH="${XTB_ROOT}" \
	-DBLAS_LIBRARY="-lopenblas" \
	-DWITH_API=TRUE \
	-DBUILD_SHARED_LIBS=TRUE \
	-DWITH_SDFTD3=TRUE \
	-B_build .
EOF

#运行cmake进行设置（如果报错，请从第1步和这一步重来！）
./../run_install_dftbplus_amber_cmake.sh
```

3. 编译和安装

```bash
make -C _build
make -C _build install
```

4. 准备一个modulefile文件用于加载dftb+环境，最好把它放到MODULEPATH中的路径中，方便用module load加载环境。它包含以下内容：

```bash
cat > 24.1_amber24 <<EOF
#%Module
set prefix /lustre/home/acct-zouyike/luoshenggan/software/dftbplus/dftbplus-amber

setenv DFTBPLUS_ROOT $prefix

setenv OMP_STACKSIZE 3000m

module-whatis "DFTB+ Program Package"

prepend-path LD_LIBRARY_PATH $prefix/lib64
prepend-path PATH $prefix/bin
prepend-path PKG_CONFIG_PATH $prefix/lib64/pkgconfig

# Only allow to load one instance of xtb
conflict dftbplus

EOF
```

## 3. Plumed

1. 下载

```bash
wget https://github.com/plumed/plumed2/releases/download/v2.9.0/plumed-2.9.0.tgz
```

2. 解压

```bash
tar zxvf plumed-2.9.0.tgz
```

3. 安装

```bash
mkdir -p plumed/plumed-2.9.0
cd plumed-2.9.0
./configure --prefix=/lustre/home/acct-zouyike/luoshenggan/software/plumed/plumed-2.9.0
make -j 4
make doc
make install

```

4. 把生成的modulefile复制到指定文件夹(此处为~/.mymodulefiles/plumed)中，用于设定软件运行环境

```bash
mkdir -p ~/.mymodulefiles/plumed
cp plumed/plumed-2.9.0/lib/plumed/modulefile ~/.mymodulefiles/plumed/2.9.0
```

## 2. Lio (貌似安装不了，GPU硬件的问题？)

1. 申请交互结点

```bash
srun -p cpu -n 40 --exclusive --pty /bin/bash
```

2. 下载软件包

```bash
git clone https://github.com/MALBECC/lio.git
```

3. 编译

```bash
module load cuda/11.8.0
cd lio/
make cuda=1 cpu=0

```

## 3. Amber22/24

amber 22和24的安装方法基本上一样，安装的时候路径需要进行相应的修改而且有些BUG在更新之后就不用另外打补丁了

**3.1 申请交互作业结点（PI 2.0集群和思源一号集群申请的命令稍微有点区别）**

```bash
srun -p cpu -n 40 --exclusive --pty /bin/bash   #PI 2.0
module load gcc/11.2.0
```

**3.2 下载源码包并解压 (官网下载源码)**

```bash
tar jxvf AmberTools23.tar.bz2
tar jxvf Amber22.tar.bz2    #amber24需要改成24对应的软件包
```

**3.3 Amber源码补丁更新（不然安装parmed会报错，amber24不用打补丁，发行方已经更正好了）**

```bash
cp amber22.patch amber22_src/
cd amber22_src/    #amber24 只运行这一行，注意路径名
patch -p1 < amber22.patch
```

**3.4 设置第三方库环境变量（如PLUMED, 需要自己额外安装PLUMED）**

```bash
#amber22运行以下命令加载plumed环境（plumed需要提前安装，参考上面plumed安装过程，这个文件没有加载cuda，后面安装gpu版本的时候要加载cuda）
source ../amberplumed.sh

#amber24运行以下命令加载环境（包括cuda,plumed,dftbplus和xtb，plumed,dftbplus和xtb需要提前安装，参考上面PLUMED,DFTB+和XTB的安装过程）
# module load plumed/2.9.0
# module load cuda/11.8.0
# module load xtb/6.7.0_amber24 #确保设置了XTB_ROOT变量，不然编译不能编译或者直接运行下一行
## export XTB_ROOT=/lustre/home/acct-zouyike/luoshenggan/software/xtb/xtb-amber24
# module load dftbplus/24.1_amber24
```

**3.5 安装 (更新补丁-加上-DBUILD_QUICK=TRUE运行cmake后安装)**

amber24额外加上-DUSE_XTB=TRUE -DBUILD_TCPB=TRUE -DLIBTORCH=TRUE -DUSE_DFTBPLUS=TRUE

```bash
cd build/
cp ../../runcmakeBuild22.patch .  #amber24运行 cp ../../runcmakeBuild24.patch .
patch < runcmakeBuild22.patch     #amber24运行 patch < runcmakeBuild24.patch
./run_cmake

make install
```

**3.6 初始化Amber测试环境**

```bash
source ../../amber22/amber.sh   #amer24注意路径
```

**3.7 串行CPU版本测试**

```bash
cd $AMBERHOME
make test.serial   # ~ 1.5 h   amber24注意加载xtb,dftbplus环境来测试xtb和dftbplus QM/MM接口
```

**在确保大部分串行CPU测试通过时再编译串行GPU版本**

**3.8 串行GPU版本编译，加载CUDA环境**

```bash
module load cuda/11.8.0   #amber24在上面已经加载过cuda/11.8.0了，可以不运行，运行也无妨
cd ../amber22_src/build   #amber24注意路径名  cd ../amber24_src/build/
```

**3.9 编辑run_cmake文件，把-DCUDA=FALSE选项设为-DCUDA=TRUE后保存**

```bash
vi run_cmake
```

**3.10 编译和安装串行GPU版本**

```bash
./run_cmake
make install    # ~ 2 h
```

**3.11 测试串行GPU版本**

```bash
cd $AMBERHOME

export CUDA_VISIBLE_DEVICES=0
make test.cuda.serial           # ~ 20 min

```

注意：因为在CPU结点编译的串行GPU版本，你需要将上面的测试命令放到作业脚本并用sbatch命令提交到GPU结点上运行。**并且需要在测试作业脚本中设置好AMBER的环境（PLUMED库，source amber.sh等等）**

**在确保大部分串行GPU测试通过再编译并行CPU版本**

**3.12 编译openmpi,下载openmpi软件包到相应的文件夹中并利用amber提供的脚本进行编译**

```bash
# amber 22
cd ../amber22_src/AmberTools/src/    #注意：手册上写的路径是错误的！
wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.6.tar.bz2  
tar jxvf openmpi-4.1.6.tar.bz2

#amber24 安装5.0.1
# cd ../amber24_src/AmberTools/src/
# wget https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.1.tar.bz2
# tar jxvf openmpi-5.0.1.tar.bz2

#amber22或24安装openmpi
./configure_openmpi -static -np 4 gnu   # ~ 15 min
```

**3.13 编辑run_cmake文件把-DMPI=FALSE设为-DMPI=TRUE并且-DCUDA=TRUE设为-DCUDA=FALSE**

```bash
cd ../../build
vi run_cmake
```

**3.14 编译和安装CPU并行版本**

```bash
./run_cmake
make install
```

**3.15 测试CPU并行版本（最好以作业脚本的形式提交-注意加载plumed，xtb(amber24), dftbplus(amber24)及openmpi环境变量设定）**

openmpi 4.x及5.0.1运行需要设定特殊的环境变量

```bash
cd $AMBERHOME
source amber.sh
export OMPI_MCA_btl=^openib    #openmpi环境变量（amber22）amber24安装的是openmpi5.0.1,应该不用设定这个环境变量？
#amber24应设定下一行：
# export `mpirun env | grep OMPI_MCA_orte_precondition_transports`
export DO_PARALLEL="mpirun -np 2" #2个线程并行
make test.parallel

export DO_PARALLEL="mpirun -np 4"
make test.parallel
```

大部分CPU并行版本测试通过再编译GPU并行版本

**3.16 编辑run_cmake文件，把-DCUDA=FALSE设为-DCUDA=TRUE**

```bash
cd ../amber22_src/build   #amber24运行  cd ../amber24_src/build
vi run_cmake
```

**3.17 编译GPU并行版本**

```bash
./run_cmake
make install
```

**3.18 测试GPU并行版本(以作业脚本的形式提交，注意plumed，xtb(amber24), dftbplus(amber24)环境和openmpi的环境的设置)**

```bash
cd $AMBERHOME
source amber.sh
export OMPI_MCA_btl=^openib    #openmpi环境变量
#amber24应设定下一行：
# export `mpirun env | grep OMPI_MCA_orte_precondition_transports`
export DO_PARALLEL="mpirun -np 2" #2个线程并行
make test.cuda.parallel
```

## 4. Tcl-ChemShell

1 安装Tcl，假设你已经在~/software目录下

```bash
mkdir tcl
mv tcl8.5.11-src.tar.gz tcl
cd tcl/
tar zxvf tcl8.5.11-src.tar.gz  #生成一个新的文件夹 tcl8.5.11
mkdir tcl-8.5.11 #新建tcl-8.5.11作为安装路径
cd tcl8.5.11/unix/
./configure --prefix=/lustre/home/acct-zouyike/luoshenggan/software/tcl/tcl-8.5.11   #指定了刚刚新建的用于安装的路径
make
make install
#设置tcl环境变量用于安装 chemshell
export TCLROOT=/lustre/home/acct-zouyike/luoshenggan/software/tcl/tcl-8.5.11
export LIBTCL=/lustre/home/acct-zouyike/luoshenggan/software/tcl/tcl-8.5.11/lib/libtcl8.5.so

```

2 安装chemshell，假设你已经在~/software目录下

```bash
mkdir chemsh
mv chemsh-3.7.1.tar.gz chemsh
cd chemsh/
tar zxvf chemsh-3.7.1.tar.gz
cd chemsh-3.7.1/src/config/

export CC=gcc
export F77=gfortran
export F90=gfortran
./configure
cd ..
make
```

3 测试安装的ChemShell

```bash
cd ../examples/
./run_validation.tcsh

```
