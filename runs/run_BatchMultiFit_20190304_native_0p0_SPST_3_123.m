(* screen -d -m xvfb-run MathKernel -noprompt -run "<<run_BatchMultiFit_20190304_native_0p0_SPST_3_123.m" >> run_BatchMultiFit_20190304_native_0p0_SPST_3_123.log & *)

(* Load BatchMultiFit program *)
Get["/home/martins/projects/BatchMultiFit/BatchMultiFit.m"];

(* define number of threads, using more than >6 threads causes the vncserver crashing (?!) *)
CloseKernels[]
LaunchKernels[16]
$KernelCount


SetDirectory["/home/martins/projects/BatchMultiFit"];



(* Load XNDiff output data, Y-files *)
YFileDir="out/";
YFileList=FileNames[YFileDir<>"SSS_180x360_P*_ST_*_N50_OSL_SPST_3.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;



(* diffuse SAS range strong structure factor due to high conc, which is not accounted by the stack structure factor -> consider fitting s > 0.05 only *)

(* with ycohscf(0.5-2.5), T, DiffEvol ign. start values, use chi/cdConstr *)
(*
OutDir="MathematicaOut/SSS_0p0BC_native_OSL_SPST_3_001/";
Xnmode="X";
expfileconc={"export/im_0051252_caz_CapB_0p0BC_native-H2O_s-scaled_sIdI.chi",0.30};
Nmaxsp=6;
Nmaxst=5;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.05;
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
cdConstr={True,{"chi",True,0.5}}; (* Default for cdConstr[[2]] *)
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag,PlotFlag,cdConstr]][[1]]]
*)

(*
-> does not fit, d_i usually 0.0, D=(211,)213,215,217(,220) would be actually a better range for D, use 1.0, 1.5 and 2.0 for dR
-> c_i=3,4 (weigthed as in dil) with smaller disl+dosl might be good as well since Bragg peak is too wide with c_i=3 only, 4*45+2*16 = 212 <= min(D), i.e. only half of stabilizer layer
-> form factor indicates that it is quite important to include 1 and 3,4 sp
-> 215_100_*_3.log : xmgrace -legend load -log xy SSS_180x360_P016_016_ST_215_100_N50_OSL_SPST_3_X_st_0[2-4].dat SSS_180x360_P016_016_ST_215_100_N50_OSL_SPST_3_X_sp_0[1-5].dat /home/martins/projects/BatchMultiFit/export/im_0051252_caz_CapB_0p0BC_native-H2O_s-scaled_sIdI.chi &
*)



(* with ycohscf(0.5-2.5), T, FindMinimum w/ start values, use chi/cdConstr *)
(* same as OSL_SPST_3_003/, fixed c_i from OSL_005/ fits *)
(*
OutDir="MathematicaOut/SSS_0p0BC_native_OSL_SPST_3_003/";
Xnmode="X";
expfileconc={"export/im_0051252_caz_CapB_0p0BC_native-H2O_s-scaled_sIdI.chi",0.30};
Nmaxsp=6;
Nmaxst=5;
FitFunc=FindMinimum;
FitMethod="Automatic";
Fitsmin=0.05;
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
cdConstr={True,{"chi",True,0.5}}; (* Default for cdConstr[[2]] *)
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag,PlotFlag,cdConstr]][[1]]]
*)

(* with ycohscf(0.5-2.5), T, FindMinimum w/ start values, do not use chi/cdConstr i.e. fit directly c_i and d_i *)
OutDir="MathematicaOut/SSS_0p0BC_native_OSL_SPST_3_005/";
Xnmode="X";
expfileconc={"export/im_0051252_caz_CapB_0p0BC_native-H2O_s-scaled_sIdI.chi",0.30};
Nmaxsp=6;
Nmaxst=5;
FitFunc=FindMinimum;
FitMethod="Automatic";
Fitsmin=0.05;
Fitsmax=0.37;
FitMaxIt=10000;
FitTarF=T;
ParStart={{"c1",True,0.06},{"c2",True,0.05},{"c3",True,0.2},{"c4",True,0.15},{"c5",False,0.02},{"c6",False,0.02},{"d2",True,0.125},{"d3",True,0.125},{"d4",True,0.125},{"d5",True,0.125},{"rhoisl",True,325,"300<#<360"},{"rhoosl",True,350,"300<#<360"},{"rhodm",True,335,"333<#<340"},{"Xa",True,0.02,"0.001<#<0.025"}};
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
cdConstr={False,{"chi",True,0.0(*,Constraint*)}}; (* {False,{"chi",True,0.0(*,Constraint*)}} is default *)
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag,PlotFlag,cdConstr]][[1]]]



(* Load XNDiff output data, Y-files *)
(*
YFileDir="out/";
YFileList=FileNames[YFileDir<>"SSS_180x360_P*_ST_*_N50_OSL_SPST_123.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;
*)




(* use always Exit[] *)
Exit[]

