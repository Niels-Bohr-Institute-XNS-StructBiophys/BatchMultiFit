(* screen -d -m xvfb-run MathKernel -noprompt -run "<<run_BatchMultiFit_20200216_native_STMOD3_nis_totd.m" >> run_BatchMultiFit_20200216_native_STMOD3_nis_totd.log & *)

(* Load BatchMultiFit program *)
Get["/home/martins/projects/BatchMultiFit/BatchMultiFit.m"];

CloseKernels[]
LaunchKernels[15]
$KernelCount


SetDirectory["/home/martins/projects/BatchMultiFit"];




(* diffuse SAS range strong structure factor due to high conc, which is not accounted by the stack structure factor -> consider fitting s > 0.06 only *)






(* Load XNDiff output data, Y-files *)
YFileDir="out/";
YFileList=FileNames[YFileDir<>"SSS_180x360_P*_STMOD3_nis_totd_N50_OSL_ASSYM_7p5BC_native_v2corr.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;

    


(* with ycohscf(0.5-2.5), T, w/ start values from OSL_005/ fits, DiffEvol ign. start values for di and chi, use chi/cdConstr with constraint 0.0<chi<0.5 *)

OutDir="MathematicaOut/SSS_7p5BC_native_STMOD3_nis_totd_OSL_011_v2corr/";
Xnmode="X";
expfileconc={"export/im_0051266_caz_CapA_7p5BC_native-H2O_s-scaled_sIdI.chi",0.30};
Nmaxsp=6;
Nmaxst=3;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.06;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",False,0.386579},{"c2",False,0.174448},{"c3",False,0.379504},{"c4",False,0.0524882},{"c5",False,0.00698154},{"c6",False,0.00000001},{"d2",True,0.5},{"d3",True,0.5},{"rhoisl",True,325,"300<#<360"},{"rhoosl",True,350,"300<#<360"},{"rhodm",True,335,"333<#<340"},{"Xa",True,0.02,"0.001<#<0.025"}};
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



(* with ycohscf(0.5-2.5), T, w/ start values from OSL_005/ fits, DiffEvol ign. start values for di and chi, use chi/cdConstr with constraint 0.0<chi<0.7 *)
(* same as 011_v2/ but with 0<chi<0.7 i.e. max 70% sp and min 30% stacks, and max 3er stacks *)

OutDir="MathematicaOut/SSS_7p5BC_native_STMOD3_nis_totd_OSL_013_v2corr/";
Xnmode="X";
expfileconc={"export/im_0051266_caz_CapA_7p5BC_native-H2O_s-scaled_sIdI.chi",0.30};
Nmaxsp=6;
Nmaxst=3;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.06;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",False,0.386579},{"c2",False,0.174448},{"c3",False,0.379504},{"c4",False,0.0524882},{"c5",False,0.00698154},{"c6",False,0.00000001},{"d2",True,0.5},{"d3",True,0.5},{"rhoisl",True,325,"300<#<360"},{"rhoosl",True,350,"300<#<360"},{"rhodm",True,335,"333<#<340"},{"Xa",True,0.02,"0.001<#<0.025"}};
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
cdConstr={True,{"chi",True,0.0,"0.0<#<0.7"}}; (* {False,{"chi",True,0.0(*,Constraint*)}} is default *)
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag,PlotFlag,cdConstr]][[1]]]



(* use always Exit[] *)
Exit[]

