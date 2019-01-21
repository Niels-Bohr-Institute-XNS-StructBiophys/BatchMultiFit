(* in bash use: nice MathKernel -noprompt -run "<<run_BatchMultiFit_20181130.m" >> run_BatchMultiFit_20181130_v003.log & *)

(*

Needs ErrorBarLogPlots.m in the same directory as BatchMultiFit.m
Download it from http://library.wolfram.com/infocenter/MathSource/6747/

For the export of the pictures the frontend will be always invoked for rendering -> needs X !

Just in case if you are running the script remotely in a terminal on a server you can e.g. use a VNC-server as X:

-start on the server a VNC-server via tyoing in the terminal: 
 vncserver :1 [-alwaysshared] [-localhost]

-in the terminal: 
 export DISPLAY=<server-IP>:1  [or export DISPLAY=localhost:1]
 nice MathKernel -noprompt -run "<<run_BatchMultiFit.m" >> run_BatchMultiFit.log &

-Note that some VNC-servers (TightVNC) may crash if there are more than 6 parallel jobs.
-Using NX can be an alternative.

*)

(*
SLDs

	Formula		Density [g/cm3]	SLD [10^-6 Å^-2]	ED [e-/nm^3]
betaSSS	C57H110O6	1.058		10.098			358.4
betaCAR	C40H56		0.941		8.827			313.3
Water	H2O		0.998		9.450			335.4
*)


Get["/home/martins/projects/BatchMultiFit_SF/BatchMultiFit.m"];



(* define number of threads, using more than >6 threads causes the vncserver crashing (?!) *)
CloseKernels[]
LaunchKernels[8]
$KernelCount


SetDirectory["/home/martins/projects/BatchMultiFit_SF"];



(* dilute SSS suspension *)
YFileDir="out/";
YFileList=FileNames[YFileDir<>"SSS_180x360_P*_ST_360_400_N100.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;



(* with ycohscf, T *)
(*
OutDir="MathematicaOut/SSS_3pBC_native_001/";
Xnmode="X";
expfileconc={"export/im_0047237_caz_s-scaled_sIdI.chi",0.2}; (* scale with approx. overall SSS onc *)
Nmaxsp=5;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.01;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",True,0.0},{"c2",True,0.3},{"c3",True,0.4},{"c4",True,0.3},{"c5",True,0.0},{"rhoisl",True,0,"270<#<370"},{"rhoosl",True,0,"270<#<370"},{"rhodm",True,0,"333<#<345"},{"Xa",True,0.005,"0.006<#<0.018"}};
PlRange={{0.002,0.5},{10^-3,10^2}};
plsc=1; (* Default *)
Ymode=1; (* Default *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1,"0.3<#<3"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag]][[1]]];
*)



(* with ycohscf, T *)
(*
OutDir="MathematicaOut/SSS_5pBC_native_001/";
Xnmode="X";
expfileconc={"export/im_0047239_caz_s-scaled_sIdI.chi",0.2}; (* scale with approx. overall SSS onc *)
Nmaxsp=5;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.01;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",True,0.0},{"c2",True,0.3},{"c3",True,0.4},{"c4",True,0.3},{"c5",True,0.0},{"rhoisl",True,0,"270<#<370"},{"rhoosl",True,0,"270<#<370"},{"rhodm",True,0,"333<#<345"},{"Xa",True,0.005,"0.006<#<0.018"}};
PlRange={{0.002,0.5},{0.003,300}};
plsc=1; (* Default *)
Ymode=1; (* Default *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1,"0.3<#<3"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag]][[1]]];
*)

(* with ycohscf, T *)
(*
OutDir="MathematicaOut/SSS_7p5pBC_native_001/";
Xnmode="X";
expfileconc={"export/im_0047240_caz_s-scaled_sIdI.chi",0.2}; (* scale with approx. overall SSS onc *)
Nmaxsp=5;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.01;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",True,0.0},{"c2",True,0.3},{"c3",True,0.4},{"c4",True,0.3},{"c5",True,0.0},{"rhoisl",True,0,"270<#<370"},{"rhoosl",True,0,"270<#<370"},{"rhodm",True,0,"333<#<345"},{"Xa",True,0.005,"0.006<#<0.018"}};
PlRange={{0.002,0.5},{0.003,300}};
plsc=1; (* Default *)
Ymode=1; (* Default *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1,"0.3<#<3"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag]][[1]]];
*)




(* with ycohscf, T, fixed rhoisl to BC *)
OutDir="MathematicaOut/SSS_3pBC_native_002/";
Xnmode="X";
expfileconc={"export/im_0047237_caz_s-scaled_sIdI.chi",0.2}; (* scale with approx. overall SSS onc *)
Nmaxsp=5;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.007;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",True,0.0},{"c2",True,0.3},{"c3",True,0.4},{"c4",True,0.3},{"c5",True,0.0},{"rhoisl",False,313},{"rhoosl",True,0,"270<#<370"},{"rhodm",True,0,"333<#<340"},{"Xa",True,0.005,"0.006<#<0.018"}};
PlRange={{0.002,0.5},{10^-3,10^2}};
plsc=1; (* Default *)
Ymode=1; (* Default *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1,"0.3<#<3"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag]][[1]]];




(* with ycohscf, T, fixed rhoisl to BC *)
OutDir="MathematicaOut/SSS_5pBC_native_002/";
Xnmode="X";
expfileconc={"export/im_0047239_caz_s-scaled_sIdI.chi",0.2}; (* scale with approx. overall SSS onc *)
Nmaxsp=5;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.007;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",True,0.0},{"c2",True,0.3},{"c3",True,0.4},{"c4",True,0.3},{"c5",True,0.0},{"rhoisl",False,313},{"rhoosl",True,0,"270<#<370"},{"rhodm",True,0,"333<#<340"},{"Xa",True,0.005,"0.006<#<0.018"}};
PlRange={{0.002,0.5},{0.003,300}};
plsc=1; (* Default *)
Ymode=1; (* Default *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1,"0.3<#<3"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag]][[1]]];


(* with ycohscf, T, fixed rhoisl to BC *)
OutDir="MathematicaOut/SSS_7p5pBC_native_002/";
Xnmode="X";
expfileconc={"export/im_0047240_caz_s-scaled_sIdI.chi",0.2}; (* scale with approx. overall SSS onc *)
Nmaxsp=5;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.007;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",True,0.0},{"c2",True,0.3},{"c3",True,0.4},{"c4",True,0.3},{"c5",True,0.0},{"rhoisl",False,313},{"rhoosl",True,0,"270<#<370"},{"rhodm",True,0,"333<#<340"},{"Xa",True,0.005,"0.006<#<0.018"}};
PlRange={{0.002,0.5},{0.003,300}};
plsc=1; (* Default *)
Ymode=1; (* Default *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1,"0.3<#<3"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag]][[1]]];




(* with ycohscf, T, fixed rhoosl to BC *)
OutDir="MathematicaOut/SSS_3pBC_native_003/";
Xnmode="X";
expfileconc={"export/im_0047237_caz_s-scaled_sIdI.chi",0.2}; (* scale with approx. overall SSS onc *)
Nmaxsp=5;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.007;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",True,0.0},{"c2",True,0.3},{"c3",True,0.4},{"c4",True,0.3},{"c5",True,0.0},{"rhoisl",True,0,"270<#<370"},{"rhoosl",False,313},{"rhodm",True,0,"333<#<340"},{"Xa",True,0.005,"0.006<#<0.018"}};
PlRange={{0.002,0.5},{10^-3,10^2}};
plsc=1; (* Default *)
Ymode=1; (* Default *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1,"0.3<#<3"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag]][[1]]];




(* with ycohscf, T, fixed rhoosl to BC *)
OutDir="MathematicaOut/SSS_5pBC_native_003/";
Xnmode="X";
expfileconc={"export/im_0047239_caz_s-scaled_sIdI.chi",0.2}; (* scale with approx. overall SSS onc *)
Nmaxsp=5;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.007;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",True,0.0},{"c2",True,0.3},{"c3",True,0.4},{"c4",True,0.3},{"c5",True,0.0},{"rhoisl",True,0,"270<#<370"},{"rhoosl",False,313},{"rhodm",True,0,"333<#<340"},{"Xa",True,0.005,"0.006<#<0.018"}};
PlRange={{0.002,0.5},{0.003,300}};
plsc=1; (* Default *)
Ymode=1; (* Default *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1,"0.3<#<3"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag]][[1]]];


(* with ycohscf, T, fixed rhoosl to BC *)
OutDir="MathematicaOut/SSS_7p5pBC_native_003/";
Xnmode="X";
expfileconc={"export/im_0047240_caz_s-scaled_sIdI.chi",0.2}; (* scale with approx. overall SSS onc *)
Nmaxsp=5;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="DifferentialEvolution";
Fitsmin=0.007;
Fitsmax=0.37;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",True,0.0},{"c2",True,0.3},{"c3",True,0.4},{"c4",True,0.3},{"c5",True,0.0},{"rhoisl",True,0,"270<#<370"},{"rhoosl",False,313},{"rhodm",True,0,"333<#<340"},{"Xa",True,0.005,"0.006<#<0.018"}};
PlRange={{0.002,0.5},{0.003,300}};
plsc=1; (* Default *)
Ymode=1; (* Default *)
AddConstraints={}; (* Default *)
Smear={0,0.0}; (* Default *)
Tscf=1.0; (* Default *)
ycohscf={True,1,"0.3<#<3"};
LicoConstr={"","==1.0"}; (* Default *)
ExportFlag=True;
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,Ymode,AddConstraints,Smear,Tscf,ycohscf,LicoConstr,ExportFlag]][[1]]];



(* use always Exit[] *)
Exit[]
