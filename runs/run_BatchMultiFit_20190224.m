(* screen -d -m xvfb-run MathKernel -noprompt -run "<<run_BatchMultiFit_20190224.m" >> run_BatchMultiFit_20190224.log & *)

(* Load BatchMultiFit program *)
Get["/home/martins/projects/BatchMultiFit/BatchMultiFit.m"];

(* define number of threads, using more than >6 threads causes the vncserver crashing (?!) *)
CloseKernels[]
LaunchKernels[16]
$KernelCount


SetDirectory["/home/martins/projects/BatchMultiFit"];



(* Load XNDiff output data, Y-files for dilute SSS suspension *)
YFileDir="out/";
YFileList=FileNames[YFileDir<>"SSS_180x360_P*_ST_230_200_N50_OSL.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;





(* with ycohscf(0.5-2.5), T *)
(* fix c_i to those from dil and used in simulation of stacks to ensure same platelets btw dil and native *)
(* diffuse SAS range strong structure factor due to high conc, which is not accounted by the stack structure factor -> consider fitting s > 0.05 only *)
(* diff tw native and dilute diffuse SAS is less for loaded samples, would ideally require new sim with their c_i *)
OutDir="MathematicaOut/SSS_0p0BC_native_OSL_003/";
Xnmode="X";
expfileconc={"export/im_0051252_caz_CapB_0p0BC_native-H2O_s-scaled_sIdI.chi",0.30};
Nmaxsp=6;
Nmaxst=5;
FitFunc=NMinimize;
FitMethod="SimulatedAnnealing";
Fitsmin=0.05;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",False,0.052586},{"c2",False,0.004511},{"c3",False,0.420543},{"c4",False,0.356191},{"c5",False,0.119113},{"c6",False,0.047056},{"d2",True,0.25,"0.0<#<1.0"},{"d3",True,0.25,"0.0<#<1.0"},{"d4",True,0.25,"0.0<#<1.0"},{"d5",True,0.25,"0.0<#<1.0"},{"rhoisl",True,0,"300<#<360"},{"rhoosl",True,0,"300<#<360"},{"rhodm",True,0,"333<#<340"},{"Xa",True,0.02,"0.001<#<0.025"}};
PlRange={{0.002,0.5},{10^-2,10^2}};
plsc=1; (* Default *)
Ymode=1; (* Default *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1.0,"0.5<#<2.5"};
LicoConstr={"","==1.0"}; (* Default *)
cdConstr={True,{"chi",True,0.0}}; (* Default for cdConstr[[2]] *)
ExportFlag=True;
PlotFlag=False;
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag,PlotFlag,cdConstr]][[1]]]





(* use always Exit[] *)
Exit[]

