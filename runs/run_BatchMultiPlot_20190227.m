(* screen -d -m xvfb-run MathKernel -noprompt -run "<<run_BatchMultiPlot_20190227.m" >> run_BatchMultiPlot_20190227.log & *)

(* Load BatchMultiFit program *)
Get["/home/martins/projects/BatchMultiFit/BatchMultiFit.m"];



(* define number of threads, using more than >6 threads causes the vncserver crashing (?!) *)
CloseKernels[]
LaunchKernels[2]
$KernelCount


SetDirectory["/home/martins/projects/BatchMultiFit"];



(* 0p0 1to5dil 005/ with VCRY conc *)


(* Load XNDiff output data *)
(* Yfiles must match those from fits !!! *)
YFileDir="out/";
YFileList=FileNames[YFileDir<>"SSS_180x360_P020_012_ST_360_400_N50.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;

(*plot*)
(*
OutDir="MathematicaOut/SSS_0p0BC_1to5dil_005_plot/";
Xnmode="X";
expfileconc={"export/im_0051238_caz_CapA_0p0BC_1to5dil-H2O_s-scaled_sIdI.chi",0.0317};
Nmaxsp=6;
Nmaxst=0;
Fitsmin=0.0085;
Fitsmax=0.37;
ParStart={{c1,0.032053385302814985},{c2,0.00380853290626513},{c3,0.40738885090460203},{c4,0.37248711779810617},{c5,0.13080247766979128},{c6,0.05345963541842051},{rhoisl,339.7994207886524},{rhoosl,351.74919667231154},{rhodm,339.9999999999851},{Xa,0.002442059619763633}};
ycohscf={1.9281761050267368};
PlRange={{0.002,0.5},{10^-3,10^2}};
plsc=1;(*Default is 1 *)
Ymode=1;(*Default is 1 *)
Smear={0,0.0};(*Default*)
Tscf=1.0;(*Default is 1.0 *)
PlotFlag=True;(*Default is True *)
ow=True;(*Default is False *)
BatchMultiPlot[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,Fitsmin,Fitsmax,ParStart,ycohscf,PlRange,plsc,Ymode,Smear,Tscf,PlotFlag,ow]
*)


(* 0p0 1to5dil OSL_005/ with VOSL conc *)

(* Load XNDiff output data *)
(* Yfiles must match those from fits !!! *)
YFileDir="out/";
YFileList=FileNames[YFileDir<>"SSS_180x360_P020_012_ST_360_400_N50_OSL.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;

(*plot*)
(*
OutDir="MathematicaOut/SSS_0p0BC_1to5dil_OSL_005_plot/";
Xnmode="X";
expfileconc={"export/im_0051238_caz_CapA_0p0BC_1to5dil-H2O_s-scaled_sIdI.chi",0.05};
Nmaxsp=6;
Nmaxst=0;
Fitsmin=0.0085;
Fitsmax=0.37;
ParStart={{c1,0.052586372247525714},{c2,0.004510639736581632},{c3,0.42054301527185284},{c4,0.35619147143577523},{c5,0.11911260635744349},{c6,0.047055894950821076},{rhoisl,339.79942098618864},{rhoosl,351.7491919219455},{rhodm,339.9999999998499},{Xa,0.00244205907423795}};
ycohscf={1.8187777296904648};
PlRange={{0.002,0.5},{10^-3,10^2}};
plsc=1;(*Default is 1 *)
Ymode=1;(*Default is 1 *)
Smear={0,0.0};(*Default*)
Tscf=1.0;(*Default is 1.0 *)
PlotFlag=True;(*Default is True *)
ow=True;(*Default is False *)
BatchMultiPlot[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,Fitsmin,Fitsmax,ParStart,ycohscf,PlRange,plsc,Ymode,Smear,Tscf,PlotFlag,ow]
*)



(* 0p0 1to5dil OSL_005/ with VOSL conc *)

(* Load XNDiff output data *)
(* Yfiles must match those from fits !!! *)
YFileDir="out/";
YFileList=FileNames[YFileDir<>"SSS_180x360_P012_040_ST_360_400_N50_OSL.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;

(*plot*)
OutDir="MathematicaOut/SSS_3p0BC_1to5dil_OSL_005_plot/";
Xnmode="X";
expfileconc={"export/im_0051239_caz_CapB_3p0BC_1to5dil-H2O_s-scaled_sIdI.chi",0.05};
Nmaxsp=6;
Nmaxst=0;
Fitsmin=0.0085;
Fitsmax=0.37;
ParStart={{c1,0.2603335056982107},{c2,0.09871976690753799},{c3,0.3666043432215503},{c4,0.16358030480959962},{c5,0.08142956400372214},{c6,0.029332515359379186},{rhoisl,324.5557663966116},{rhoosl,340.3200337156504},{rhodm,337.90644817452437},{Xa,0.0011974203824816794}};
ycohscf={1.9793317758617377};
PlRange={{0.002,0.5},{10^-3,10^2}};
plsc=1;(*Default is 1 *)
Ymode=1;(*Default is 1 *)
Smear={0,0.0};(*Default*)
Tscf=1.0;(*Default is 1.0 *)
PlotFlag=True;(*Default is True *)
ow=True;(*Default is False *)
BatchMultiPlot[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,Fitsmin,Fitsmax,ParStart,ycohscf,PlRange,plsc,Ymode,Smear,Tscf,PlotFlag,ow]





(* use always Exit[] *)
Exit[]


