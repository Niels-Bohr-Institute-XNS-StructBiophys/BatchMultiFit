(* screen -d -m xvfb-run MathKernel -noprompt -run "<<run_BatchMultiFit_20190126.m" >> run_BatchMultiFit_20190126.log & *)

(* Load BatchMultiFit program *)
Get["/home/martins/projects/BatchMultiFit/BatchMultiFit.m"];

(* define number of threads, using more than >6 threads causes the vncserver crashing (?!) *)
CloseKernels[]
LaunchKernels[16]
$KernelCount


SetDirectory["/home/martins/projects/BatchMultiFit"];



(* Load XNDiff output data, Y-files for dilute SSS suspension *)
YFileDir="out/";
YFileList=FileNames[YFileDir<>"SSS_180x360_P*_ST_360_400_N50_OSL.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;




(* with ycohscf(0.75-1.25), T *)
OutDir="MathematicaOut/SSS_0p0BC_1to5dil_OSL_007/";
Xnmode="X";
expfileconc={"export/im_0051238_caz_CapA_0p0BC_1to5dil-H2O_s-scaled_sIdI.chi",0.05};
Nmaxsp=6;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.0085;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",True,0.2},{"c2",True,0.3},{"c3",True,0.3},{"c4",True,0.1},{"c5",True,0.1},{"c6",True,0.0},{"rhoisl",True,0,"270<#<400"},{"rhoosl",True,0,"270<#<400"},{"rhodm",False,334},{"Xa",True,0.002,"0.001<#<0.005"}};
PlRange={{0.002,0.5},{10^-3,10^2}};
plsc=1; (* Default *)
Ymode=1; (* Default *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1.0,"0.75<#<1.25"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag]][[1]]]

(* with ycohscf(0.75-1.25), T *)
OutDir="MathematicaOut/SSS_3p0BC_1to5dil_OSL_007/";
Xnmode="X";
expfileconc={"export/im_0051239_caz_CapB_3p0BC_1to5dil-H2O_s-scaled_sIdI.chi",0.05};
Nmaxsp=6;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.0085;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",True,0.2},{"c2",True,0.3},{"c3",True,0.3},{"c4",True,0.1},{"c5",True,0.1},{"c6",True,0.0},{"rhoisl",True,0,"270<#<400"},{"rhoosl",True,0,"270<#<400"},{"rhodm",False,334},{"Xa",True,0.002,"0.001<#<0.005"}};PlRange={{0.002,0.5},{10^-3,10^2}};
plsc=1; (* Default *)
Ymode=1; (* Default *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1.0,"0.75<#<1.25"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag]][[1]]];



(* use always Exit[] *)
Exit[]

