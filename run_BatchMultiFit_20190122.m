(* nice MathKernel -noprompt -run "<<run_BatchMultiFit.m" >> run_BatchMultiFit_20190122.log & *)

(* Load BatchMultiFit program *)
Get["/home/martins/projects/BatchMultiFit_SF/BatchMultiFit.m"];

(* define number of threads, using more than >6 threads causes the vncserver crashing (?!) *)
CloseKernels[]
LaunchKernels[16]
$KernelCount


SetDirectory["/home/martins/projects/BatchMultiFit_SF"];



(* Load XNDiff output data, Y-files for dilute SSS suspension *)
YFileDir="out/";
YFileList=FileNames[YFileDir<>"SSS_180x360_P*_ST_360_400_N50.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;



(* with ycohscf, {Chi2,"red"}, with dI *)
OutDir="MathematicaOut/SSS_3p0BC_1to5dil_006/";
Xnmode="X";
expfileconc={"export/im_0051239_caz_CapB_3p0BC_1to5dil-H2O_s-scaled_sIdI.chi",0.0267};
Nmaxsp=6;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.0085;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF={Chi2,"red"};
ParStart={{"c1",True,0.0},{"c2",True,0.1},{"c3",True,0.4},{"c4",True,0.4},{"c5",True,0.1},{"c6",True,0.0},{"rhoisl",True,0,"270<#<400"},{"rhoosl",True,0,"270<#<400"},{"rhodm",True,0,"333<#<340"},{"Xa",True,0.002,"0.001<#<0.005"}};PlRange={{0.002,0.5},{10^-3,10^2}};
plsc=1; (* Default *)
Ymode=1; (* Default *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1.0,"0.5<#<2.0"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag]][[1]]];


(* with ycohscf, {Chi2,"red"}, with dI *)
OutDir="MathematicaOut/SSS_5p0BC_1to5dil_006/";
Xnmode="X";
expfileconc={"export/im_0051247_caz_CapA_5p0BC_1to5dil-H2O_s-scaled_sIdI.chi",0.0233};
Nmaxsp=6;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.0085;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF={Chi2,"red"};
ParStart={{"c1",True,0.0},{"c2",True,0.1},{"c3",True,0.4},{"c4",True,0.4},{"c5",True,0.1},{"c6",True,0.0},{"rhoisl",True,0,"270<#<400"},{"rhoosl",True,0,"270<#<400"},{"rhodm",True,0,"333<#<340"},{"Xa",True,0.002,"0.001<#<0.005"}};PlRange={{0.002,0.5},{10^-3,10^2}};
plsc=1; (* Default *)
Ymode=1; (* Default *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1.0,"0.5<#<2.0"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag]][[1]]];


(* with ycohscf, {Chi2,"red"}, with dI *)
OutDir="MathematicaOut/SSS_7p5BC_1to5dil_006/";
Xnmode="X";
expfileconc={"export/im_0051251_caz_CapA_7p5BC_1to5dil-H2O_s-scaled_sIdI.chi",0.0192};
Nmaxsp=6;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.0085;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF={Chi2,"red"};
ParStart={{"c1",True,0.0},{"c2",True,0.1},{"c3",True,0.4},{"c4",True,0.4},{"c5",True,0.1},{"c6",True,0.0},{"rhoisl",True,0,"270<#<400"},{"rhoosl",True,0,"270<#<400"},{"rhodm",True,0,"333<#<340"},{"Xa",True,0.002,"0.001<#<0.005"}};PlRange={{0.002,0.5},{10^-3,10^2}};
plsc=1; (* Default *)
Ymode=1; (* Default *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1.0,"0.5<#<2.0"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag]][[1]]];



(* use always Exit[] *)
Exit[]


