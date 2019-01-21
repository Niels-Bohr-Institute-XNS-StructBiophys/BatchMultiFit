(* in bash use: nice MathKernel -noprompt -run "<<run_BatchMultiFit_20180809.m" >> run_BatchMultiFit_20180809.log & *)

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



Get["BatchMultiFit.m"];



(* define number of threads, using more than >6 threads causes the vncserver crashing (?!) *)
CloseKernels[]
LaunchKernels[4]
$KernelCount


SetDirectory["/home/martins/projects/BatchMultiFit_SF"];



(* diluted suspensions *)



(* 0.5 Angstroem steps *)
YFileDir="output/";
YFileList=FileNames[YFileDir<>"PPP_180x360_P*_ST_379_200_N100_v02.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;



(* diluted DLPC *)

(* with ycohscf, with LicoConstr, AddContraints: 3 constraints for same water (without extra H2O) penetration levels in SAXS and SANS with correlation between isl and osl, n-Smear=1 *)
OutDir="MathematicaOut/011_3/";
Xnmode={"X","n"};
expfileconc={
{"export/Hecus331_03-D2O-30C.dat",0.03},
{"export/JCNS331_03-30C.dat",0.03}};
Nmaxsp=5;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="SimulatedAnnealing";
Fitsmin=0.015;
Fitsmax=0.45;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",True},{"c2",True},{"c3",True},{"c4",True},{"c5",True},{"rhoisl",True,0,"267<#<345"},{"rhoosl",True,0,"333<#<514"},{"rhodm",True,0,"333<#<345"},{"Xa",True,0.001,"0.001<#<0.0065"},{"sldisl",True,0,"-0.39<#<6.36"},{"sldosl",True,0,"1.88<#<6.36"},{"slddm",False,6.36},{"na",True,0.01,"0.01<#<0.063"}};
PlRange={{0.004,0.7},{10^-4,10^5}};
plsc={0.1,1};
AddConstraints={"sldisl==(-rhodm*sldchain+rhoisl*(sldchain-sldd2o)+rhochain*sldd2o)/(rhochain-rhodm)/.{rhohead->514,rhochain->267,sldhead->1.88,sldchain->-0.39,sldd2o->6.36,Vhead->319,Vchain->667}","sldosl==sldd2o+(rhodm-rhoisl)/(rhochain-rhodm)*(sldd2o-sldhead)*Vhead/Vchain*ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{3,5}]]/ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{7,9}]]/.{rhohead->514,rhochain->267,sldhead->1.88,sldchain->-0.39,sldd2o->6.36,Vhead->319,Vchain->667}","rhoosl==rhodm+(rhodm-rhohead)*(rhodm-rhoisl)/(rhochain-rhodm)*Vhead/Vchain*ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{3,5}]]/ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{7,9}]]/.{rhohead->514,rhochain->267,sldhead->1.88,sldchain->-0.39,sldd2o->6.36,Vhead->319,Vchain->667}"};
Smear={{0,0.0},{1,0.2}};
ycohscf={{True,1.0,"0.8<#<1.2"},{False,1.0}};
LicoConstr={"0.8<","<1.2"};
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,1,AddConstraints,Smear,1.0,ycohscf,LicoConstr,True]][[1]]];



(* diluted DOPC *)

(* with ycohscf, with LicoConstr, AddContraints: 3 constraints for same water (without extra H2O) penetration levels in SAXS and SANS with correlation between isl and osl, n-Smear=1 *)
OutDir="MathematicaOut/013_3/";
Xnmode={"X","n"};
expfileconc={
{"export/Hecus337_03-D2O-30C.dat",0.03},
{"export/JCNS337_03-30C.dat",0.03}};
Nmaxsp=5;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="SimulatedAnnealing";
Fitsmin=0.02;
Fitsmax=0.45;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",True},{"c2",True},{"c3",True},{"c4",True},{"c5",True},{"rhoisl",True,0,"274<#<345"},{"rhoosl",True,0,"333<#<514"},{"rhodm",True,0,"333<#<345"},{"Xa",True,0.001,"0.001<#<0.004"},{"sldisl",True,0,"-0.21<#<6.36"},{"sldosl",True,0,"1.88<#<6.36"},{"slddm",False,6.36},{"na",True,0.01,"0.01<#<0.07"}};
PlRange={{0.004,0.7},{10^-4,10^5}};
plsc={0.1,1};
AddConstraints={"sldisl==(-rhodm*sldchain+rhoisl*(sldchain-sldd2o)+rhochain*sldd2o)/(rhochain-rhodm)/.{rhohead->514,rhochain->274,sldhead->1.88,sldchain->-0.21,sldd2o->6.36,Vhead->319,Vchain->984}","sldosl==sldd2o+(rhodm-rhoisl)/(rhochain-rhodm)*(sldd2o-sldhead)*Vhead/Vchain*ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{3,5}]]/ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{7,9}]]/.{rhohead->514,rhochain->274,sldhead->1.88,sldchain->-0.21,sldd2o->6.36,Vhead->319,Vchain->984}","rhoosl==rhodm+(rhodm-rhohead)*(rhodm-rhoisl)/(rhochain-rhodm)*Vhead/Vchain*ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{3,5}]]/ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{7,9}]]/.{rhohead->514,rhochain->274,sldhead->1.88,sldchain->-0.21,sldd2o->6.36,Vhead->319,Vchain->984}"};
Smear={{0,0.0},{1,0.2}};
ycohscf={{True,1.0,"0.8<#<1.2"},{False,1.0}};
LicoConstr={"0.8<","<1.2"};
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,1,AddConstraints,Smear,1.0,ycohscf,LicoConstr,True]][[1]]];



(* diluted S100 *)

(* with ycohscf, with LicoConstr, AddContraints: 3 constraints for same water (without extra H2O) penetration levels in SAXS and SANS with correlation between isl and osl, n-Smear=1 *)
OutDir="MathematicaOut/015_3/";
Xnmode={"X","n"};
expfileconc={
{"export/Hecus319_03-D2O-30C.dat",0.03},
{"export/JCNS319_03-30C.dat",0.03}};
Nmaxsp=5;
Nmaxst=0;
FitFunc=NMinimize;
FitMethod="SimulatedAnnealing";
Fitsmin=0.02;
Fitsmax=0.45;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",True},{"c2",True},{"c3",True},{"c4",True},{"c5",True},{"rhoisl",True,0,"274<#<345"},{"rhoosl",True,0,"333<#<514"},{"rhodm",True,0,"333<#<345"},{"Xa",True,0.001,"0.001<#<0.004"},{"sldisl",True,0,"-0.21<#<6.36"},{"sldosl",True,0,"1.88<#<6.36"},{"slddm",False,6.36},{"na",True,0.01,"0.01<#<0.07"}};
PlRange={{0.004,0.7},{10^-4,10^5}};
plsc={0.1,1};
AddConstraints={"sldisl==(-rhodm*sldchain+rhoisl*(sldchain-sldd2o)+rhochain*sldd2o)/(rhochain-rhodm)/.{rhohead->514,rhochain->274,sldhead->1.88,sldchain->-0.21,sldd2o->6.36,Vhead->319,Vchain->984}","sldosl==sldd2o+(rhodm-rhoisl)/(rhochain-rhodm)*(sldd2o-sldhead)*Vhead/Vchain*ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{3,5}]]/ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{7,9}]]/.{rhohead->514,rhochain->274,sldhead->1.88,sldchain->-0.21,sldd2o->6.36,Vhead->319,Vchain->984}","rhoosl==rhodm+(rhodm-rhohead)*(rhodm-rhoisl)/(rhochain-rhodm)*Vhead/Vchain*ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{3,5}]]/ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{7,9}]]/.{rhohead->514,rhochain->274,sldhead->1.88,sldchain->-0.21,sldd2o->6.36,Vhead->319,Vchain->984}"};
Smear={{0,0.0},{1,0.2}};
ycohscf={{True,1.0,"0.8<#<1.2"},{False,1.0}};
LicoConstr={"0.8<","<1.2"};
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,1,AddConstraints,Smear,1.0,ycohscf,LicoConstr,True]][[1]]];



(* native suspensions *)



(* native S100 *)

(* 36.0 nm +/- 2,3,4 nm, cis from 015_3, 0.5 Angstroem steps *)
YFileDir="output/";
YFileList=FileNames[YFileDir<>"PPP_180x360_P*_ST_360_*_N100_319.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;


(* with ycohscf, with LicoConstr, AddContraints: 3 constraints for same water (without extra H2O) penetration levels in SAXS and SANS with correlation between isl and osl, Nst=3, fix ci *)
OutDir="MathematicaOut/028_3/";
Xnmode={"X","n"};
expfileconc={
{"export/Hecus319-D2O-30C.dat",0.1},
{"export/JCNS319-30C.dat",0.1}};
Nmaxsp=5;
Nmaxst=3;
FitFunc=NMinimize;
FitMethod="SimulatedAnnealing";
Fitsmin=0.015;
Fitsmax=0.45;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",False,0.09663},{"c2",False,0.27126},{"c3",False,0.34061},{"c4",False,0.20170},{"c5",False,0.06904},{"d2",True},{"d3",True},{"rhoisl",True,0,"274<#<345"},{"rhoosl",True,0,"333<#<514"},{"rhodm",True,0,"333<#<345"},{"Xa",True,0.001,"0.001<#<0.008"},{"sldisl",True,0,"-0.21<#<6.36"},{"sldosl",True,0,"1.88<#<6.36"},{"slddm",False,6.36},{"na",True,0.01,"0.01<#<0.153"}};
PlRange={{0.004,0.7},{10^-4,10^5}};
plsc={0.1,1};
AddConstraints={"sldisl==(-rhodm*sldchain+rhoisl*(sldchain-sldd2o)+rhochain*sldd2o)/(rhochain-rhodm)/.{rhohead->514,rhochain->274,sldhead->1.88,sldchain->-0.21,sldd2o->6.36,Vhead->319,Vchain->984}","sldosl==sldd2o+(rhodm-rhoisl)/(rhochain-rhodm)*(sldd2o-sldhead)*Vhead/Vchain*ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{3,5}]]/ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{7,9}]]/.{rhohead->514,rhochain->274,sldhead->1.88,sldchain->-0.21,sldd2o->6.36,Vhead->319,Vchain->984}","rhoosl==rhodm+(rhodm-rhohead)*(rhodm-rhoisl)/(rhochain-rhodm)*Vhead/Vchain*ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{3,5}]]/ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{7,9}]]/.{rhohead->514,rhochain->274,sldhead->1.88,sldchain->-0.21,sldd2o->6.36,Vhead->319,Vchain->984}"};
Smear={{0,0.0},{1,0.2}};
ycohscf={{True,1.0,"0.8<#<1.2"},{False,1.0}};
LicoConstr={"0.8<","<1.2"};
cdConstr={True,{"chi",True,0.0}};
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,1,AddConstraints,Smear,1.0,ycohscf,LicoConstr,True,False,cdConstr]][[1]]];



(* native DOPC *)

(* 36.0 nm +/- 2,3,4 nm, cis from 013_3, 0.5 Angstroem steps *)
YFileDir="output/";
YFileList=FileNames[YFileDir<>"PPP_180x360_P*_ST_360_*_N100_337.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;


(* with ycohscf, with LicoConstr, AddContraints: 3 constraints for same water (without extra H2O) penetration levels in SAXS and SANS with correlation between isl and osl, Nst=3, fix ci *)
OutDir="MathematicaOut/034_3/";
Xnmode={"X","n"};
expfileconc={
{"export/Hecus337-D2O-30C.dat",0.1},
{"export/JCNS337-30C.dat",0.1}};
Nmaxsp=5;
Nmaxst=3;
FitFunc=NMinimize;
FitMethod="SimulatedAnnealing";
Fitsmin=0.015;
Fitsmax=0.45;
FitMaxIt=1000;
FitTarF=T;
ParStart={{"c1",False,0.15976},{"c2",False,0.29428},{"c3",False,0.33429},{"c4",False,0.14982},{"c5",False,0.05008},{"d2",True},{"d3",True},{"rhoisl",True,0,"274<#<345"},{"rhoosl",True,0,"333<#<514"},{"rhodm",True,0,"333<#<345"},{"Xa",True,0.001,"0.001<#<0.0074"},{"sldisl",True,0,"-0.21<#<6.36"},{"sldosl",True,0,"1.88<#<6.36"},{"slddm",False,6.36},{"na",True,0.01,"0.01<#<0.165"}};
PlRange={{0.004,0.7},{10^-4,10^5}};
plsc={0.1,1};
AddConstraints={"sldisl==(-rhodm*sldchain+rhoisl*(sldchain-sldd2o)+rhochain*sldd2o)/(rhochain-rhodm)/.{rhohead->514,rhochain->274,sldhead->1.88,sldchain->-0.21,sldd2o->6.36,Vhead->319,Vchain->984}","sldosl==sldd2o+(rhodm-rhoisl)/(rhochain-rhodm)*(sldd2o-sldhead)*Vhead/Vchain*ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{3,5}]]/ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{7,9}]]/.{rhohead->514,rhochain->274,sldhead->1.88,sldchain->-0.21,sldd2o->6.36,Vhead->319,Vchain->984}","rhoosl==rhodm+(rhodm-rhohead)*(rhodm-rhoisl)/(rhochain-rhodm)*Vhead/Vchain*ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{3,5}]]/ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{7,9}]]/.{rhohead->514,rhochain->274,sldhead->1.88,sldchain->-0.21,sldd2o->6.36,Vhead->319,Vchain->984}"};
Smear={{0,0.0},{1,0.2}};
ycohscf={{True,1.0,"0.8<#<1.2"},{False,1.0}};
LicoConstr={"0.8<","<1.2"};
cdConstr={True,{"chi",True,0.0}};
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,1,AddConstraints,Smear,1.0,ycohscf,LicoConstr,True,False,cdConstr]][[1]]];



(* native DOPC *)

(* 37.9 nm +/- 2,3,4 nm, cis from 011_3, 0.5 Angstroem steps *)
YFileDir="output/";
YFileList=FileNames[YFileDir<>"PPP_180x360_P*_ST_379_*_N100_331.log"];
YFileList=StringTrim[StringTrim[#,YFileDir],".log"]&/@YFileList;



(* with ycohscf, with LicoConstr, AddContraints: 3 constraints for same water (without extra H2O) penetration levels in SAXS and SANS with correlation between isl and osl, Nst=3, fix ci *)
OutDir="MathematicaOut/031_3/";
Xnmode={"X","n"};
expfileconc={
{"export/Hecus331-D2O-30C.dat",0.1},
{"export/JCNS331-30C.dat",0.1}};
Nmaxsp=5;
Nmaxst=3;
FitFunc=NMinimize;
FitMethod="SimulatedAnnealing";
Fitsmin=0.015;
Fitsmax=0.45;
FitMaxIt=1000;
FitTarF=T;
plsc={0.1,1};
ParStart={{"c1",False,0.07944},{"c2",False,0.50111},{"c3",False,0.29033},{"c4",False,0.0},{"c5",False,0.03632},{"d2",True},{"d3",True},{"rhoisl",True,0,"267<#<345"},{"rhoosl",True,0,"333<#<514"},{"rhodm",True,0,"333<#<345"},{"Xa",True,0.001,"0.001<#<0.007"},{"sldisl",True,0,"-0.39<#<6.36"},{"sldosl",True,0,"1.88<#<6.36"},{"slddm",False,6.36},{"na",True,0.01,"0.01<#<0.14"}};
PlRange={{0.004,0.7},{10^-4,10^5}};
AddConstraints={"sldisl==(-rhodm*sldchain+rhoisl*(sldchain-sldd2o)+rhochain*sldd2o)/(rhochain-rhodm)/.{rhohead->514,rhochain->267,sldhead->1.88,sldchain->-0.39,sldd2o->6.36,Vhead->319,Vchain->667}","sldosl==sldd2o+(rhodm-rhoisl)/(rhochain-rhodm)*(sldd2o-sldhead)*Vhead/Vchain*ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{3,5}]]/ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{7,9}]]/.{rhohead->514,rhochain->267,sldhead->1.88,sldchain->-0.39,sldd2o->6.36,Vhead->319,Vchain->667}","rhoosl==rhodm+(rhodm-rhohead)*(rhodm-rhoisl)/(rhochain-rhodm)*Vhead/Vchain*ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{3,5}]]/ToExpression[StringTake[StringCases[YFileListGlobal[[Y,1]],\"_P\"~~__~~\"_ST\"][[1]],{7,9}]]/.{rhohead->514,rhochain->267,sldhead->1.88,sldchain->-0.39,sldd2o->6.36,Vhead->319,Vchain->667}"};
Smear={{0,0.0},{1,0.2}};
ycohscf={{True,1.0,"0.8<#<1.2"},{False,1.0}};
LicoConstr={"0.8<","<1.2"};
cdConstr={True,{"chi",True,0.0}};
Print[AbsoluteTiming[BatchMultiFit[OutDir,Xnmode,expfileconc,YFileDir,YFileList,Nmaxsp,Nmaxst,FitFunc,FitMethod,Fitsmin,Fitsmax,FitMaxIt,FitTarF,ParStart,PlRange,plsc,1,AddConstraints,Smear,1.0,ycohscf,LicoConstr,True,False,cdConstr]][[1]]];



(* use always Exit[] *)
Exit[]
