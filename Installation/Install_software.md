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

setenv g16root `realpath g16.A03`
puts stderr "g16root of \${red}g16.A03\$reset is set"
puts stderr "\t* add \$green source \\\$g16root/g16/bsd/g16.profile \$reset to your job scripts"

conflict g16
EOF
```

安装完成，下面提交简单任务测试。

1.3 准备好高斯输入文件，假设有高斯计算任务(文件名为 test.com)。

1.4 使用辅助脚本生成高斯任务作业脚本并提交到slurm作业管理系统

```bash
genslm_g16 test.com  #将会生成作业脚本文件slm_g16_test.sh
sbatch slm_g16_test.sh  #提交高斯作业
```

1.5 结束后将会得到计算结果文件（test.log）及一些其他的输出文件。

## 2. RoseTTAFold-All-Atom (还没有安装)

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

## 3. XTB

3.0 切换到默认安装路径并申请交互计算资源：

```bash
# 切换到默认安装路径，思源一号：
cd /dssg/home/acct-zouyike/share/software
# 如果是PI 2.0，运行下一行命令
#cd /lustre/home/acct-zouyike/share/software

# 申请交互操作资源，思源一号：
srun -p 64c512g -n 4 --pty /bin/bash
# 如果是PI 2.0，运行下一行申请交互操作资源
# srun -p cpu -n 4 --pty /bin/bash
```

3.1 下载xtb最新版本（当前为6.7.0）

```bash
# 在默认安装路径下运行如下命令
mkdir xtb
cd xtb
git clone https://github.com/grimme-lab/xtb.git
module load gcc/11.2.0   #加载gcc 11.2.0版本，因为用gfortran 8.5编译会报错！

## 在PI 2.0上用gcc8.5.0编译git clone下载的包报错！但是编译直接下载的源码包成功。比如通过下面的方式下载：
## wet https://github.com/grimme-lab/xtb/releases/download/v6.7.0/xtb-6.7.0-source.tar.xz
## 还是建议使用11.2.0编译git clone下载的源代码
```

3.2 建立xtb安装目录

```bash
mkdir xtb-amber24
cd xtb

#如果使用8.5.0编译下载的压缩包，参考以下命令
# tar Jxvf xtb-6.7.0-source.tar.xz #解压后会有一个文件夹“xtb-6.7.0/”，如果使用git clone 下载的，不用解压就有文件夹“xtb”
# mkdir xtb-amber24  #新建xtb的安装路径
# cd xtb-6.7.0     #xtb-6.7.0 的源代码路径
```

3.3 运行cmake设置

```bash
#把cmake命令放到上一级目录的一个文件中，这样每次报错重新安装不用再输入这么长的命令！
#PS：运行xtb的cmkae命令极易报错！因为它需要从github上下载其他代码
cat > ../run_xtb_amber_install_cmake.sh <<EOF
#!/bin/bash
export XTBHOME=`realpath ../xtb-amber24/`
export FC=gfortran
export CC=gcc
cmake -B_build \
	-DCMAKE_BUILD_TYPE=RelWithDebInfo \
	-DBUILD_SHARED_LIBS=TRUE \
	-DINSTALL_MODULES=TRUE \
	-DCMAKE_EXE_LINKER_FLAGS="-lm" \
	-DBLAS_LIBRARIES="-lopenblas" \
	-DLAPACK_LIBRARIES="-lopenblas" \
	-DCMAKE_INSTALL_PREFIX=\${XTBHOME}
EOF

# 给它增加执行权限
chmod +x ../run_xtb_amber_install_cmake.sh

#运行cmake进行设置（如果报错，请从第1，2步和这一步重来！）
./../run_xtb_amber_install_cmake.sh

```

3.4 编译和安装

```bash
# 在这之前先确保libopenblas.so能够被找到，思源一号 上运行如下一行命令加载HPC预装的openblas库
module load openblas/0.3.24
# 如果在PI 2.0上安装，运行下一行命令加载openblas库
#module load openblas/0.3.23-gcc-8.5.0

make -C _build
make -C _build install  #安装完成后应该在安装目录下有/lib64/libxtb.so, include/xtb.h, inclue/xtb_type_solvation.mod

```

3.5 在modulefiles/xtb中准备一个modulefile文件用于加载xtb环境，把它放到MODULEPATH中的路径中，方便用module load加载环境。它包含以下内容：

```bash
# 切换到默认安装路径，思源一号：
cd /dssg/home/acct-zouyike/share/software
# 如果是PI 2.0，运行下一行命令
#cd /lustre/home/acct-zouyike/share/software

# 运行如下命令准备modulefile文件

# 建立存放xtb module files文件的文件夹
mkdir -p modulefiles/xtb

# 在该文件夹中生成modulefiles文件,xtb版本为6.7.0，暂且用这个文件名吧
cat > modulefiles/xtb/6.7.0_amber24 <<EOF
#%Module
set prefix `realpath xtb/xtb-amber24/`

setenv XTB_ROOT \$prefix
setenv OMP_NUM_THREADS 40
setenv MKL_NUM_THREADS 40
setenv OMP_STACKSIZE 3000m

module-whatis "Semiempirical Extended Tight-Binding Program Package"

prepend-path LD_LIBRARY_PATH \$prefix/lib64
prepend-path XTBPATH \$prefix/share/xtb
prepend-path PATH \$prefix/bin
prepend-path MANPATH \$prefix/share/man
prepend-path PKG_CONFIG_PATH \$prefix/lib64/pkgconfig

# Only allow to load one instance of xtb
conflict xtb
EOF

```

## 4. DFTB+

4.0 切换到默认安装路径并申请交互计算资源：

```bash
# 切换到默认安装路径，思源一号：
cd /dssg/home/acct-zouyike/share/software
# 如果是PI 2.0，运行下一行命令
#cd /lustre/home/acct-zouyike/share/software

# 申请交互操作资源
srun -p 64c512g -n 4 --pty /bin/bash
# 如果是PI 2.0，运行下一行申请交互操作资源
# srun -p cpu -n 4 --pty /bin/bash
```

4.1 下载DFTB+

```bash
mkdir dftbplus
cd dftbplus
git clone https://github.com/dftbplus/dftbplus.git

# 加载gcc 11.2.0
module load gcc/11.2.0

# 确保libopenblas.so能够被找到，思源一号 上运行如下一行命令加载HPC预装的openblas库
module load openblas/0.3.24
# 如果在PI 2.0上安装，运行下一行命令加载openblas库
#module load openblas/0.3.23-gcc-8.5.0

mkdir dftbplus-amber24/
cd dftbplus
```

4.2 运行cmake设置

```bash
# 把cmake命令放到上一级目录的一个文件中，这样每次报错重新安装不用再输入这么长的命令！
cat > ../run_install_dftbplus_amber_cmake.sh <<EOF
#!/bin/bash

export DFTBPLUSHOME=`realpath ../dftbplus-amber24/`
export FC=gfortran
export CC=gcc
module load xtb/6.7.0_amber24
cmake -DCMAKE_INSTALL_PREFIX=\${DFTBPLUSHOME} \
	-DHYBRID_CONFIG_METHODS="Find" \
	-DCMAKE_PREFIX_PATH="\${XTB_ROOT}" \
	-DBLAS_LIBRARY="-lopenblas" \
	-DWITH_API=TRUE \
	-DBUILD_SHARED_LIBS=TRUE \
	-DWITH_SDFTD3=TRUE \
	-B_build .
EOF

# 增加执行权限
chmod +x ../run_install_dftbplus_amber_cmake.sh

#运行cmake进行设置（如果报错，请从第1步和这一步重来！）
./../run_install_dftbplus_amber_cmake.sh
```

4.3 编译和安装

```bash
make -C _build
make -C _build install
```

4.4 准备一个modulefile文件用于加载dftb+环境，把它放到MODULEPATH中的路径中，方便用module load加载环境。它包含以下内容：

```bash
# 切换到默认安装路径，思源一号：
cd /dssg/home/acct-zouyike/share/software
# 如果是PI 2.0，运行下一行命令
#cd /lustre/home/acct-zouyike/share/software

# 运行如下命令准备modulefile文件

# 建立存放dftbplus module files文件的文件夹
mkdir -p modulefiles/dftbplus

# 在该文件夹中生成modulefiles文件,dftbplus版本为24.1，暂且用这个文件名吧
cat > modulefiles/dftbplus/24.1_amber24 <<EOF
#%Module
set prefix `realpath dftbplus/dftbplus-amber24/`

setenv DFTBPLUS_ROOT \$prefix

setenv OMP_STACKSIZE 3000m

module-whatis "DFTB+ Program Package"

prepend-path LD_LIBRARY_PATH \$prefix/lib64
prepend-path PATH \$prefix/bin
prepend-path PKG_CONFIG_PATH \$prefix/lib64/pkgconfig

# Only allow to load one instance of dftbplus
conflict dftbplus

EOF
```

## 5. Plumed

5.0 切换到默认安装路径：

```bash
# 切换到默认安装路径，思源一号：
cd /dssg/home/acct-zouyike/share/software
# 如果是PI 2.0，运行下一行命令
#cd /lustre/home/acct-zouyike/share/software

# 申请交互操作资源
srun -p 64c512g -n 4 --pty /bin/bash
# 如果是PI 2.0，运行下一行申请交互操作资源
# srun -p cpu -n 4 --pty /bin/bash
```

5.1 下载源码安装包

```bash
wget https://github.com/plumed/plumed2/releases/download/v2.9.0/plumed-2.9.0.tgz
```

5.2 解压安装包

```bash
tar zxvf plumed-2.9.0.tgz
```

5.3 运行如下命令进行安装

```bash
# 新建一个文件夹用于安装所有各个版本的plumed
mkdir -p plumed/plumed-2.9.0

# 进入源代码文件夹编译
cd plumed-2.9.0
# 加载gcc 11.2.0
module load gcc/11.2.0
./configure --prefix=`realpath ../plumed/plumed-2.9.0/`
make -j 4
make doc
make install

```

5.4 把生成的modulefile复制到专门存放modulefile的文件夹(此处为默认安装路径下的modulefiles/plumed)中，用于设定软件运行环境,同时加上设置PLUMED_ROOT的代码

```bash
# 切换到默认安装路径，思源一号：
cd /dssg/home/acct-zouyike/share/software
# 如果是PI 2.0，运行下一行命令
#cd /lustre/home/acct-zouyike/share/software

mkdir -p modulefiles/plumed
cp plumed/plumed-2.9.0/lib/plumed/modulefile modulefiles/plumed/2.9.0

# 在modulefiles中设置PLUMED_ROOT变量，在安装Amber 22/24的时候要用到
sed -i $\a'#set PLUMED_ROOT for Amber 22 or 24 installation\nsetenv PLUMED_ROOT '`realpath plumed/plumed-2.9.0` modulefiles/plumed/2.9.0

# 安装完成后删除解压的源代码文件夹
rm -r plumed-2.9.0/
```

## 6. Lio (貌似安装不了，暂不安装！)

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

## 7. Amber22/24

amber 22和24的安装方法基本上一样，安装的时候路径需要进行相应的修改而且有些BUG在Amber 24不用另外打补丁了

注意：如果要使**Amber24**具有XTB和DFTB+的功能，最好先按照前面3和4的安装步骤把XTB和DFTB+安装完成

7.0 切换到默认安装路径：

```bash
# 切换到默认安装路径，思源一号：
cd /dssg/home/acct-zouyike/share/software
# 如果是PI 2.0，运行下一行命令
#cd /lustre/home/acct-zouyike/share/software
```

**7.1 申请交互作业结点（PI 2.0集群和思源一号集群申请的命令有区别）**

```bash
# 思源一号：
srun -p 64c512g -n 64 --exclusive --pty /bin/bash
# 如果是PI 2.0，运行下一行申请交互操作资源
# srun -p cpu -n 40 --exclusive --pty /bin/bash

# 加载 gcc 11.2.0
module load gcc/11.2.0

# 加载合适的cmake版本-3.21.4 (在思源一号上使用系统自带的cmake 3.20.2和3.26.5版本安装dftbplus库时会报错)
module load cmake/3.21.4-gcc-11.2.0
```

**7.2 下载源码包并解压 (官网下载源码)**

```bash
# Amber 24, 解压后会有一个文件夹amber24_src/
tar jxvf AmberTools24.tar.bz2
tar jxvf Amber24.tar.bz2
# 进入Amber 24源代码文件夹
cd amber24_src/
# 在思源一号上安装GPU版本报错，打上补丁。PI 2.0也有可能报错，最好也打补丁
cp ../CMakeLists.txt.patch ./
patch < CMakeLists.txt.patch

# Amber 22运行如下命令，解压后会有一个文件夹amber22_src/
#tar jxvf AmberTools23.tar.bz2
#tar jxvf Amber22.tar.bz2
# 进入Amber 22源代码文件夹
#cd amber22_src/
```

**7.3 Amber源码补丁更新（不然Amber 22安装parmed会报错；Amber 24不用打补丁，发行方已经更正好了,直接跳过这步）**

```bash
cp ../amber22.patch ./
patch -p1 < amber22.patch
```

**7.4 设置第三方库环境变量（如PLUMED等, 需要自己额外安装PLUMED）**

```bash
# 加载openblas库，PI 2.0和思源一号预装的版本加载方式不一样
# 思源一号：
module load openblas/0.3.24
# PI 2.0:
#module load openblas/0.3.23-gcc-8.5.0

# Amber 24运行以下命令加载环境（包括cuda,plumed,dftbplus,openblas和xtb，plumed,dftbplus和xtb需要提前安装，参考上面PLUMED,DFTB+和XTB的安装过程）
module load plumed/2.9.0
module load cuda/11.8.0
module load xtb/6.7.0_amber24 #确保设置了XTB_ROOT变量，不然不能编译xtb的库。如没有设置可以直接运行下一行设置变量，把路径换成你的xtb安装路径就行
## export XTB_ROOT=/lustre/home/acct-zouyike/luoshenggan/software/xtb/xtb-amber24
module load dftbplus/24.1_amber24

# 安装Amber 22只需加载plumed和cuda环境（plumed需要提前安装，参考上面plumed安装过程），运行以下命令
#module load plumed/2.9.0
#module load cuda/11.8.0
```

**7.5 安装 (Amber 22和24的run_cmake文件加上-DBUILD_QUICK=TRUE运行cmake后安装)**

Amber24额外加上-DUSE_XTB=TRUE -DBUILD_TCPB=TRUE -DLIBTORCH=TRUE -DUSE_DFTBPLUS=TRUE

```bash
# Amber 24
cd build/
cp ../../runcmakeBuild24.patch ./
patch < runcmakeBuild24.patch
./run_cmake
make install

# Amber 22 运行以下命令
#cd build/
#cp ../../runcmakeBuild22.patch ./
#patch < runcmakeBuild22.patch   
#./run_cmake
#make install
```

**7.6 初始化Amber测试环境（可以跳过7.6 7.7，在所有版本的安装完成后统一测试）**

```bash
# Amer 24
source ../../amber24/amber.sh

# Amber 22
#source ../../amber22/amber.sh   
```

**7.7 串行CPU版本测试**

```bash
# 加载openblas库，PI 2.0和思源一号预装的版本加载方式不一样
# 思源一号：
module load openblas/0.3.24
# PI 2.0:
#module load openblas/0.3.23-gcc-8.5.0

# Amber 24
# 加载plumed,xtb,dftbplus,openblas和cuda等Amber 24运行需要的环境
module load plumed/2.9.0
module load cuda/11.8.0
module load xtb/6.7.0_amber24
module load dftbplus/24.1_amber24
cd $AMBERHOME
make test.serial

# Amber 22
# 加载plumed,cuda和openblas等Amber 22运行需要的环境
#module load plumed/2.9.0
#module load cuda/11.8.0
#cd $AMBERHOME
#make test.serial   # ~ 1.5 h
```

**在确保大部分串行CPU测试通过时再编译串行GPU版本**

**7.8 串行GPU版本编译，加载CUDA环境**

```bash
# Amber 24
module load cuda/11.8.0
# 如果你手动测试串行CPU版本（也就是运行了7.6和7.7）,那么需要运行下一行命令回到Amber 24的编译路径。如果打算以脚本方式测试，那么不用运行下一行
cd ../amber24_src/build/

# Amber 22
#module load cuda/11.8.0
# 如果你手动测试串行CPU版本（也就是运行了7.6和7.7）,那么需要运行下一行命令回到Amber 22的编译路径。如果打算以脚本方式测试，那么不用运行下一行
#cd ../amber22_src/build
```

**7.9 编辑run_cmake文件，把-DCUDA=FALSE选项设为-DCUDA=TRUE后保存**

```bash
# Amber 22/24都需要修改这个文件
vi run_cmake
```

**7.10 编译和安装串行GPU版本**

```bash
# Amber 22/24都需要运行以下命令
./run_cmake
make install    # ~ 2 h
```

**7.11 测试串行GPU版本，如果在GPU结点编译，可以直接运行下面的测试步骤，如果在CPU结点编译，跳过这步，后面以作业脚本的方式提交测试**

```bash
# 加载openblas库，PI 2.0和思源一号预装的版本加载方式不一样
# 思源一号：
module load openblas/0.3.24
# PI 2.0:
#module load openblas/0.3.23-gcc-8.5.0

# Amber 24
source ../../amber24/amber.sh
# 加载plumed,xtb,dftbplus,openblas和cuda等Amber 24运行需要的环境
module load plumed/2.9.0
module load cuda/11.8.0
module load xtb/6.7.0_amber24
module load dftbplus/24.1_amber24

# Amber 22
#source ../../amber22/amber.sh
#module load plumed/2.9.0
#module load cuda/11.8.0

# Amber 22/24 都需要运行以下命令
cd $AMBERHOME
export CUDA_VISIBLE_DEVICES=0
make test.cuda.serial   
```

注意：在CPU结点编译的串行GPU版本，你需要将上面的测试命令放到作业脚本并用sbatch命令提交到GPU结点上运行。**并且需要在测试作业脚本中设置好AMBER的环境（PLUMED库，source amber.sh等等）**

**在确保大部分串行GPU测试通过再编译并行CPU版本**

**7.12 编译openmpi,下载openmpi软件包到相应的文件夹中并利用amber提供的脚本进行编译**

```bash
# Amber24 安装5.0.1
# 如果跳过了7.11，则运行下一行命令切换路径,否则不运行
cd ../AmberTools/src    #注意：手册上写的路径是错误的！
source ../../../amber24/amber.sh
# 如果运行了7.11，则运行下一行命令切换路径，否则不运行
cd ../amber24_src/AmberTools/src/   #注意：手册上写的路径是错误的！
wget https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.1.tar.bz2
tar jxvf openmpi-5.0.1.tar.bz2

# amber 22 安装4.1.6
# 如果跳过了7.11，则运行下一行命令切换路径,否则不运行
cd ../AmberTools/src
source ../../../amber22/amber.sh
# 如果运行了7.11，则运行下一行命令切换路径，否则不运行
cd ../amber22_src/AmberTools/src/    #注意：手册上写的路径是错误的！
#wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.6.tar.bz2  
#tar jxvf openmpi-4.1.6.tar.bz2

# Amber22和24都需要运行下面命令安装openmpi
./configure_openmpi -static -np 4 gnu   # ~ 15 min
```

**7.13 编辑run_cmake文件把-DMPI=FALSE设为-DMPI=TRUE并且-DCUDA=TRUE设为-DCUDA=FALSE**

```bash
# Amber 22/24都需要运行以下命令
cd ../../build
vi run_cmake
```

**7.14 编译和安装CPU并行版本**

```bash
# Amber 22/24都需要运行以下命令
./run_cmake
make install
```

**7.15 测试CPU并行版本（以作业脚本的形式提交-注意加载plumed，xtb(amber24), dftbplus(amber24),openblas及openmpi环境变量设定）**

openmpi 4.x及5.0.1运行需要设定特殊的环境变量

```bash
# plumed, xtb, dftbplus, cuda, openblas等请参照7.11

# Amber 24
source ../../amber24/amber.sh
cd $AMBERHOME
export `mpirun env | grep OMPI_MCA_orte_precondition_transports`

# Amber 22
#source ../../amber22/amber.sh
#cd $AMBERHOME
#export OMPI_MCA_btl=^openib    #openmpi环境变量（amber22）

# Amber 22/24都需要运行以下命令
export DO_PARALLEL="mpirun -np 2" #2个线程并行
make test.parallel
export DO_PARALLEL="mpirun -np 4" #4个线程并行
make test.parallel
```

注：**直接在交互结点上运行上述测试任务会出问题，还是用脚本提交测试！**

大部分CPU并行版本测试通过再编译GPU并行版本

**7.16 编辑run_cmake文件，把-DCUDA=FALSE设为-DCUDA=TRUE**

```bash
# Amber 24
# 如果运行了7.15,运行下一行命令切换路径，否则不运行
cd ../amber24_src/build

# Amber 22
# 如果运行了7.15,运行下一行命令切换路径，否则不运行
cd ../amber22_src/build   

# Amber 22/24都需要运行以下命令
vi run_cmake
```

**7.17 编译GPU并行版本**

```bash
# Amber 22/24都需要运行以下命令
./run_cmake
make install
```

**7.18 测试GPU并行版本(以作业脚本的形式提交，注意plumed，xtb(amber24), dftbplus(amber24)环境和openmpi的环境的设置)**

```bash
# plumed, xtb, dftbplus, cuda, openblas等请参照7.11

# Amber 24
source ../../amber24/amber.sh
cd $AMBERHOME
export `mpirun env | grep OMPI_MCA_orte_precondition_transports`

# Amber 22
#source ../../amber22/amber.sh
#cd $AMBERHOME
#export OMPI_MCA_btl=^openib    #openmpi环境变量（amber22）

# Amber 22/24都需要运行以下命令
export DO_PARALLEL="mpirun -np 2" #2个线程并行
make test.cuda.parallel
```

直接在命令行上提交会出现问题，还是以作业脚本的方式提交！


**注：**Amber 24的最新补丁有问题，在AMBERHOME目录下安装了miniconda2次，第一次是安装最新版3.12，第二次安装3.11，检查了一下，3.12安装mpi4py失败，3.11安装成功。但是它把两个版本的python安装在同一个目录导致AMBERHOME目录下的miniconda目录很混乱。能用就行，不打算改Bug了。

修改AMBERHOME目录下的amber.sh文件使mpi4py能用：

```bash
# 把下面两行
export PYTHONPATH="$AMBERHOME/lib/python3.12/site-packages"
export PYTHONPATH="$AMBERHOME/lib/python3.12/site-packages:$PYTHONPATH"
# 分别修改为
export PYTHONPATH="$AMBERHOME/lib/python3.11/site-packages"
export PYTHONPATH="$AMBERHOME/lib/python3.11/site-packages:$PYTHONPATH"
```

**7.19 统一提交作业测试Amber（如果跳过了前面直接在命令行上的测试或者出现报错）。把所有测试步骤放到一个作业脚本中doAmberTest.slm，这个脚本有如下内容**

```bash
#!/bin/bash

#SBATCH --job-name=amber24test
##测试GPU：下面的队列名如果是PI 2.0设为dgx2, 思源一号设为a100或a800。如果测试CPU，队列名PI 2.0设为cpu,思源一号设为64c512g
#SBATCH --partition=64c512g
#SBATCH -N 1
#SBATCH -n 12
#SBATCH --ntasks-per-node=12
#如果是GPU队列，把下面一行的注释去掉（开头只保留一下#，串行测试把gpu后面的数字设为1，并行gpu测试把数字设为2）
##SBATCH --gres=gpu:2
#SBATCH --output=%j.out
#SBATCH --error=%j.err

module load plumed/2.9.0
module load cuda/11.8.0
# 如果思源一号
module load openblas/0.3.24
# 如果PI 2.0
#module load openblas/0.3.23-gcc-8.5.0

source amber.sh

# Amber 24 mpi xtb dftb+ setting
module load xtb/6.7.0_amber24
module load dftbplus/24.1_amber24
export `mpirun env | grep OMPI_MCA_orte_precondition_transports`

# Amber 22 mpi setting
#export OMPI_MCA_btl=^openib

# Amber 22 24都需要在CPU队列运行下面的CPU测试命令。测试时去掉下面的注释
make test.serial
export DO_PARALLEL="mpirun -np 2"
make test.parallel
export DO_PARALLEL="mpirun -np 4"
make test.parallel

# Amber 22 24都需要在GPU队列运行下面的GPU测试命令。测试时去掉下面的注释
#export CUDA_VISIBLE_DEVICES=0
#make test.cuda.serial
#export CUDA_VISIBLE_DEVICES=0,1
#make test.cuda.parallel
```

把脚本放到默认安装路径中，进入AMBERHOME提交测试作业

```bash
#切换到默认安装路径，思源一号：
cd /dssg/home/acct-zouyike/share/software
# PI 2.0
#cd /lustre/home/acct-zouyike/share/software

# Amber 24
cd amber24
# Amber 22
#cd amber22

# 提交测试作业
sbatch ../doAmberTest.slm
```

## 8. Tcl-ChemShell

8.1 安装Tcl，假设你已经在上面所说的默认安装目录下

```bash
# 切换到默认安装路径，思源一号：
cd /dssg/home/acct-zouyike/share/software
# 如果是PI 2.0，运行下一行命令
#cd /lustre/home/acct-zouyike/share/software

# 思源一号：
srun -p 64c512g -n 64 --exclusive --pty /bin/bash
# 如果是PI 2.0，运行下一行申请交互操作资源
# srun -p cpu -n 40 --exclusive --pty /bin/bash

mkdir -p tcl/tcl-8.5.11 #新建tcl-8.5.11作为安装路径
tar zxvf tcl8.5.11-src.tar.gz  #生成一个新的文件夹 tcl8.5.11
cd tcl8.5.11/unix/
./configure --prefix=`realpath ../../tcl/tcl-8.5.11`   #指定了刚刚新建的用于安装的路径
make
make install
cd ../../
rm -rf tcl8.5.11/ #删除解压的源码文件夹

#设置tcl环境变量用于安装 chemshell
export TCLROOT=`realpath tcl/tcl-8.5.11`
export LIBTCL=`realpath tcl/tcl-8.5.11/lib/libtcl8.5.so`

```

8.2 安装chemshell，假设你已经在默认安装目录下

```bash
mkdir chemsh
mv chemsh-3.7.1.tar.gz chemsh
cd chemsh/
tar zxvf chemsh-3.7.1.tar.gz
cd chemsh-3.7.1/src/config/

module unload gcc/11.2.0  #unload gcc/11.2.0,使用系统自带的gcc

export CC=gcc
export F77=gfortran
export F90=gfortran
./configure
cd ..
make
```

8.3 测试安装的ChemShell

```bash
cd ../examples/
./run_validation.tcsh

```
