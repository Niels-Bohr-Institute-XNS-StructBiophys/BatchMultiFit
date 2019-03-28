(* screen -d -m xvfb-run MathKernel -noprompt -run "<<run_BatchMultiFit_20190327_native_0p0_STMOD3.m" >> run_BatchMultiFit_20190327_native_0p0_STMOD3.log & *)

(* Load BatchMultiFit program *)
Get["/home/martins/projects/BatchMultiFit/BatchMultiFit.m"];

(* define number of threads, using more than >6 threads causes the vncserver crashing (?!) *)
CloseKernels[]
LaunchKernels[8]
$KernelCount


SetDirectory["/home/martins/projects/BatchMultiFit"];



(* Load XNDiff output data, Y-files *)
YFileDir="out/";
YFileList=FileNames[YFileDir<>"SSS_180x360_P*_STMOD3_N50_OSL.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;



(* diffuse SAS range strong structure factor due to high conc, which is not accounted by the stack structure factor -> consider fitting s > 0.06 only *)


(* with ycohscf(0.5-2.5), T, w/ start values from OSL_005/ fits, DiffEvol ign. start values for di and chi, use chi/cdConstr with constraint 0.0<chi<0.5 *)
OutDir="MathematicaOut/SSS_0p0BC_native_STMOD3_OSL_003/";
Xnmode="X";
expfileconc={"export/im_0051252_caz_CapB_0p0BC_native-H2O_s-scaled_sIdI.chi",0.30};
Nmaxsp=6;
Nmaxst=5;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.06;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",False,0.052586},{"c2",False,0.004511},{"c3",False,0.420543},{"c4",False,0.356191},{"c5",False,0.119113},{"c6",False,0.047056},{"d2",True,0.25},{"d3",True,0.25},{"d4",True,0.25},{"d5",True,0.25},{"rhoisl",True,325,"300<#<360"},{"rhoosl",True,350,"300<#<360"},{"rhodm",True,335,"333<#<340"},{"Xa",True,0.02,"0.001<#<0.025"}};
PlRange={{0.002,0.5},{10^-2,10^2}};
plsc=1; (* Default *)
Ymode=1; (* Default, only 1 type of Yfiles *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1.0,"0.5<#<2.5"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
PlotFlag=False;
cdConstr={True,{"chi",True,0.0,"0.0<#<0.5"}}; (* {False,{"chi",True,0.0(*,Constraint*)}} is default *)
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag,PlotFlag,cdConstr]][[1]]]

(* with ycohscf(0.5-2.5), T, w/ start values from OSL_005/ fits, FindMinimum using start values for di and chi, use chi/cdConstr with constraint 0.0<chi<0.5  *)
OutDir="MathematicaOut/SSS_0p0BC_native_STMOD3_OSL_005/";
Xnmode="X";
expfileconc={"export/im_0051252_caz_CapB_0p0BC_native-H2O_s-scaled_sIdI.chi",0.30};
Nmaxsp=6;
Nmaxst=5;
FitFunc=FindMinimum;
FitMethod="Automatic";
Fitsmin=0.06;
Fitsmax=0.37;
FitMaxIt=10000;
FitTarF=T;
ParStart={{"c1",False,0.052586},{"c2",False,0.004511},{"c3",False,0.420543},{"c4",False,0.356191},{"c5",False,0.119113},{"c6",False,0.047056},{"d2",True,0.25},{"d3",True,0.25},{"d4",True,0.25},{"d5",True,0.25},{"rhoisl",True,325,"300<#<360"},{"rhoosl",True,350,"300<#<360"},{"rhodm",True,335,"333<#<340"},{"Xa",True,0.02,"0.001<#<0.025"}};
PlRange={{0.002,0.5},{10^-2,10^2}};
plsc=1; (* Default *)
Ymode=1; (* Default, only 1 type of Yfiles *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1.0,"0.5<#<2.5"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
PlotFlag=False;
cdConstr={True,{"chi",True,0.25,"0.0<#<0.5"}}; (* {False,{"chi",True,0.0(*,Constraint*)}} is default *)
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag,PlotFlag,cdConstr]][[1]]]




(* use always Exit[] *)
Exit[]

