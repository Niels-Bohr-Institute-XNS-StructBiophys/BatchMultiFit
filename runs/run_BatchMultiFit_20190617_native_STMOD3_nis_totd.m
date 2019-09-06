(* screen -d -m xvfb-run MathKernel -noprompt -run "<<run_BatchMultiFit_20190617_native_STMOD3_nis_totd.m" >> run_BatchMultiFit_20190617_native_STMOD3_nis_totd.log & *)

(* Load BatchMultiFit program *)
Get["/home/martins/projects/BatchMultiFit/BatchMultiFit.m"];

(* define number of threads, using more than >6 threads causes the vncserver crashing (?!) *)
CloseKernels[]
LaunchKernels[15]
$KernelCount


SetDirectory["/home/martins/projects/BatchMultiFit"];




(* diffuse SAS range strong structure factor due to high conc, which is not accounted by the stack structure factor -> consider fitting s > 0.06 only *)


(* Load XNDiff output data, Y-files *)
YFileDir="out/";
YFileList=FileNames[YFileDir<>"SSS_180x360_P*_STMOD3_nis_totd_N50_OSL_ASSYM_0p0BC_native.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;


(* 015 does not exist for 0p0 *)

(* with ycohscf(0.5-2.5), T, w/ start values from OSL_005/ fits, DiffEvol ign. start values for di and chi, use chi/cdConstr with constraint 0.0<chi<0.6 *)
(* same as 015/ but max 3er stacks and rhos constraints *)

OutDir="MathematicaOut/SSS_0p0BC_native_STMOD3_nis_totd_OSL_017/";
Xnmode="X";
expfileconc={"export/im_0051252_caz_CapB_0p0BC_native-H2O_s-scaled_sIdI.chi",0.30};
Nmaxsp=6;
Nmaxst=3;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.06;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",False,0.0569721703},{"c2",False,0.0064034703},{"c3",False,0.4180488201},{"c4",False,0.3559066429},{"c5",False,0.1183186870},{"c6",False,0.0443502094},{"d2",True,0.5},{"d3",True,0.5},{"rhoisl",True,340,"335#<345"},{"rhoosl",True,352,"347<#<357"},{"rhodm",True,340,"337<#<340"},{"Xa",True,0.02,"0.001<#<0.025"}};
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
cdConstr={True,{"chi",True,0.0,"0.0<#<0.6"}}; (* {False,{"chi",True,0.0(*,Constraint*)}} is default *)
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag,PlotFlag,cdConstr]][[1]]]






(* Load XNDiff output data, Y-files *)
YFileDir="out/";
YFileList=FileNames[YFileDir<>"SSS_180x360_P*_STMOD3_nis_totd_N50_OSL_ASSYM_3p0BC_native.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;


(* 015 is the same as 017 for 3p0 *)

(* with ycohscf(0.5-2.5), T, w/ start values from OSL_005/ fits, DiffEvol ign. start values for di and chi, use chi/cdConstr with constraint 0.0<chi<0.6 *)
(* same as 015/ but max 3er stacks and rhos constraints *)

OutDir="MathematicaOut/SSS_3p0BC_native_STMOD3_nis_totd_OSL_015/";
Xnmode="X";
expfileconc={"export/im_0051259_caz_CapA_3p0BC_native-H2O_s-scaled_sIdI.chi",0.30};
Nmaxsp=6;
Nmaxst=3;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.06;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",False,0.26249759281607415},{"c2",False,0.09872287568105395},{"c3",False,0.36419901965372614},{"c4",False,0.16257579386053717},{"c5",False,0.0817375025739596},{"c6",False,0.03026721541464894},{"d2",True,0.5},{"d3",True,0.5},{"rhoisl",True,324,"320<#<328"},{"rhoosl",True,340,"335<#<345"},{"rhodm",True,338,"336<#<340"},{"Xa",True,0.02,"0.001<#<0.025"}};
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
cdConstr={True,{"chi",True,0.0,"0.0<#<0.6"}}; (* {False,{"chi",True,0.0(*,Constraint*)}} is default *)
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag,PlotFlag,cdConstr]][[1]]]





(* Load XNDiff output data, Y-files *)
YFileDir="out/";
YFileList=FileNames[YFileDir<>"SSS_180x360_P*_STMOD3_nis_totd_N50_OSL_ASSYM_5p0BC_native.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;


(* with ycohscf(0.5-2.5), T, w/ start values from OSL_005/ fits, DiffEvol ign. start values for di and chi, use chi/cdConstr with constraint 0.0<chi<0.6 *)

OutDir="MathematicaOut/SSS_5p0BC_native_STMOD3_nis_totd_OSL_015/";
Xnmode="X";
expfileconc={"export/im_0051260_caz_CapB_5p0BC_native-H2O_s-scaled_sIdI.chi",0.30};
Nmaxsp=6;
Nmaxst=5;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.06;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",False,0.2639479337816897},{"c2",False,0.14058843149530836},{"c3",False,0.42318427504563433},{"c4",False,0.12512727055420533},{"c5",False,0.04695408538625894},{"c6",False,0.00019800373690338766},{"d2",True,0.25},{"d3",True,0.25},{"d4",True,0.25},{"d5",True,0.25},{"rhoisl",True,325,"300<#<360"},{"rhoosl",True,350,"300<#<360"},{"rhodm",True,335,"333<#<345"},{"Xa",True,0.02,"0.001<#<0.025"}};
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
cdConstr={True,{"chi",True,0.0,"0.0<#<0.6"}}; (* {False,{"chi",True,0.0(*,Constraint*)}} is default *)
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag,PlotFlag,cdConstr]][[1]]]

(* with ycohscf(0.5-2.5), T, w/ start values from OSL_005/ fits, DiffEvol ign. start values for di and chi, use chi/cdConstr with constraint 0.0<chi<0.6 *)
(* same as 015/ but max 3er stacks and rhos constraints *)

OutDir="MathematicaOut/SSS_5p0BC_native_STMOD3_nis_totd_OSL_017/";
Xnmode="X";
expfileconc={"export/im_0051260_caz_CapB_5p0BC_native-H2O_s-scaled_sIdI.chi",0.30};
Nmaxsp=6;
Nmaxst=3;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.06;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",False,0.2639479337816897},{"c2",False,0.14058843149530836},{"c3",False,0.42318427504563433},{"c4",False,0.12512727055420533},{"c5",False,0.04695408538625894},{"c6",False,0.00019800373690338766},{"d2",True,0.5},{"d3",True,0.5},{"rhoisl",True,322,"320<#<325"},{"rhoosl",True,339,"335<#<343"},{"rhodm",True,336,"333<#<339"},{"Xa",True,0.02,"0.001<#<0.025"}};
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
cdConstr={True,{"chi",True,0.0,"0.0<#<0.6"}}; (* {False,{"chi",True,0.0(*,Constraint*)}} is default *)
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag,PlotFlag,cdConstr]][[1]]]






(* Load XNDiff output data, Y-files *)
YFileDir="out/";
YFileList=FileNames[YFileDir<>"SSS_180x360_P*_STMOD3_nis_totd_N50_OSL_ASSYM_7p5BC_native.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;


(* with ycohscf(0.5-2.5), T, w/ start values from OSL_005/ fits, DiffEvol ign. start values for di and chi, use chi/cdConstr with constraint 0.0<chi<0.6 *)

OutDir="MathematicaOut/SSS_7p5BC_native_STMOD3_nis_totd_OSL_015/";
Xnmode="X";
expfileconc={"export/im_0051266_caz_CapA_7p5BC_native-H2O_s-scaled_sIdI.chi",0.30};
Nmaxsp=6;
Nmaxst=5;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.06;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",False,0.350057},{"c2",False,0.164271},{"c3",False,0.394592},{"c4",False,0.066919},{"c5",False,0.0223924},{"c6",False,0.00176872},{"d2",True,0.25},{"d3",True,0.25},{"d4",True,0.25},{"d5",True,0.25},{"rhoisl",True,325,"300<#<360"},{"rhoosl",True,350,"300<#<360"},{"rhodm",True,335,"333<#<345"},{"Xa",True,0.02,"0.001<#<0.025"}};
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
cdConstr={True,{"chi",True,0.0,"0.0<#<0.6"}}; (* {False,{"chi",True,0.0(*,Constraint*)}} is default *)
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag,PlotFlag,cdConstr]][[1]]]


(* with ycohscf(0.5-2.5), T, w/ start values from OSL_005/ fits, DiffEvol ign. start values for di and chi, use chi/cdConstr with constraint 0.0<chi<0.6 *)
(* same as 015/ but max 3er stacks and rhos constraints *)

OutDir="MathematicaOut/SSS_7p5BC_native_STMOD3_nis_totd_OSL_017/";
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
ParStart={{"c1",False,0.350057},{"c2",False,0.164271},{"c3",False,0.394592},{"c4",False,0.066919},{"c5",False,0.0223924},{"c6",False,0.00176872},{"d2",True,0.5},{"d3",True,0.5},{"rhoisl",True,320,"315<#<325"},{"rhoosl",True,333,"330<#<335"},{"rhodm",True,333,"332<#<334"},{"Xa",True,0.02,"0.001<#<0.025"}};
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
cdConstr={True,{"chi",True,0.0,"0.0<#<0.6"}}; (* {False,{"chi",True,0.0(*,Constraint*)}} is default *)
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag,PlotFlag,cdConstr]][[1]]]



(* use always Exit[] *)
Exit[]

