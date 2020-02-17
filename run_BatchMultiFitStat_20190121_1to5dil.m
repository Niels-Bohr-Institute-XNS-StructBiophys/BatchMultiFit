(* 
How-to run:

local (desktop) machine:
MathKernel -noprompt -run "<<run_BatchMultiFitStat_20190121_1to5dil.m" > run_BatchMultiFitStat_20190416_1to5dil.log &

on a (headless) server (where no X is running):
screen -d -m xvfb-run MathKernel -noprompt -run "<<run_BatchMultiFitStat_20190121_1to5dil.m" > run_BatchMultiFitStat_20190121_1to5dil.log

Note: package xvfb-run must be installed
*)


(* Load BatchMultiFitStat program *)
SetDirectory["/home/martins/projects/BatchMultiFit"];
(* Get["/home/martins/projects/BatchMultiFit/BatchMultiFitStat.m"]; *)


Get["BatchMultiFitStat.m"];



(* simulation params for cis, disl and dosl VCRY *)

(*
Nsp=6;
mindisl=4;maxdisl=20;ddisl=2;
mindosl=4;maxdosl=20;ddosl=2;

dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_00*","",Infinity],StringMatchQ[#,{_~~"*003",_~~"*004"}]&],DirectoryQ];
*)


(*
Nsp=6;
mindisl=4;maxdisl=144;ddisl=4;
mindosl=4;maxdosl=144;ddosl=4;

dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_00*","",Infinity],StringMatchQ[#,{_~~"*005",_~~"*006"}]&],DirectoryQ];
dirlist=Select[FileNames["MathematicaOut/SSS_7p5BC_1to5dil_006","",Infinity],DirectoryQ];
*)



(* simulation params for cis, disl and dosl VOSL *)


(*
Nsp=6;
mindisl=4;maxdisl=144;ddisl=4;
mindosl=4;maxdosl=144;ddosl=4;

(* all OSL_*00[5,6]/ incl SMALLER, LARGER and HUGE *)
dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_OSL_*00*","",Infinity],StringMatchQ[#,{_~~"*005",_~~"*006"}]&],DirectoryQ];
*)





(*
Nsp=6;

(* 4:4:96 -> 300 *)
mindisl=4;maxdisl=100;ddisl=4;
mindosl=4;maxdosl=100;ddosl=4;

(* SSS_*BC_1to5dil_OSL_ASSYM_005, SSS_*BC_1to5dil_OSL_HUGE_005_more, SSS_*BC_1to5dil_OSL_LARGER_005_more and SSS_*BC_1to5dil_OSL_SMALLER_005_more *)
dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_OSL_*00*","",Infinity],StringMatchQ[#,{_~~"*005_more"}]&],DirectoryQ];
dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_OSL_ASSYM_00*","",Infinity],StringMatchQ[#,{_~~"*005"}]&],DirectoryQ];

(* 8:4:92 -> 253 *)
mindisl=8;maxdisl=92;ddisl=4;
mindosl=8;maxdosl=92;ddosl=4;
dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_OSL_ASSYM_00*","",Infinity],StringMatchQ[#,{_~~"*005"}]&],DirectoryQ];
*)




(*
Nsp=6;
mindisl=4;maxdisl=144;ddisl=4;
mindosl=4;maxdosl=144;ddosl=4;

dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_OSL_00*","",Infinity],StringMatchQ[#,{_~~"*007",_~~"*009"}]&],DirectoryQ];
*)


(*
Nsp=6;
mindisl=4;maxdisl=144;ddisl=4;
mindosl=4;maxdosl=144;ddosl=4;

dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_OSL_0*","",Infinity],StringMatchQ[#,{_~~"*011",_~~"*013",_~~"*015",_~~"*017"}]&],DirectoryQ];
*)


(* simulation params for cis, disl and dosl VOSL symmshells *)

(*
Nsp=6;
mindisl=4;maxdisl=100;ddisl=4;
mindosl=4;maxdosl=100;ddosl=4;
dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_OSL_ASSYM_symmshells_0*","",Infinity],StringMatchQ[#,{_~~"*005"}]&],DirectoryQ];
*)




(*
native samples *011_v2* *013_v2*
0p0		disl=8:4:32, dosl=8:4:32 with 24<=dtot<=48
3p0,5p0,7p5	disl=8:4:20, dosl=20:4:52 with 24<=dtot<=60
*)

(*
Nsp=6;Nst=3
mindisl=8;maxdisl=32;ddisl=4;
mindosl=8;maxdosl=32;ddosl=4;
dirlist=Select[Select[FileNames["MathematicaOut/SSS_0p0BC_native_STMOD3_nis_totd_OSL_0*","",Infinity],StringMatchQ[#,{_~~"*011_v2",_~~"*013_v2"}]&],DirectoryQ];
*)

Nsp=6;Nst=3
mindisl=8;maxdisl=20;ddisl=4;
mindosl=20;maxdosl=52;ddosl=4;
(*
dirlist=Select[Select[FileNames["MathematicaOut/SSS_3p0BC_native_STMOD3_nis_totd_OSL_0*","",Infinity],StringMatchQ[#,{_~~"*011_v2",_~~"*013_v2"}]&],DirectoryQ];
dirlist=Select[Select[FileNames["MathematicaOut/SSS_5p0BC_native_STMOD3_nis_totd_OSL_0*","",Infinity],StringMatchQ[#,{_~~"*011_v2",_~~"*013_v2"}]&],DirectoryQ];
*)
dirlist=Select[Select[FileNames["MathematicaOut/SSS_7p5BC_native_STMOD3_nis_totd_OSL_0*","",Infinity],StringMatchQ[#,{_~~"*011_v2*",_~~"*013_v2*"}]&],DirectoryQ];


Print[dirlist];

(* Trangelist={1.1,1.2,1.3,1.5}; *)
Trangelist={1.1,1.2,1.3,1.5};
UserDefinedRhosPlotRange={280,400};(*"Automatic";*)
UserDefinedCisPlotRange={0.0,0.55};(*"Automatic";*)
QuantileList={{0.25,0.75},{1.0/6.0,1.0-1.0/6.0},{0.1,0.9}};
QuantilesPlotSelector=2;
d001=44.77; (* d001 beta-SSS for nis *)

(* run *)

Do[(*dirlist*)

Do[(*Trangelist*)

Trange=Trangelist[[j]];

(* dir and log files *)
dir=dirlist[[i]];
If[StringTake[dir,-1]!="/",dir=dir<>"/"];

files=FileNames[dir<>"SSS*.log"];
files=SelectFilesdisldosl[files,mindisl,maxdisl,mindosl,maxdosl];

(* derive default fit params from log-files, disl and dosl must not be passed to DeriveTp, choices for target fnc value: "Target function values", "Chi2Red function values", "LogdI function values" *)

(*
if a param was fixed and the new BMF version was used in the fitting, it will find and process the fixed values as well, for old fits, exclude, but will crash at some point ...
lablist=Join[{"filename","disl","dosl","Target function values"},Table["c"<>ToString[i],{i,1,Nsp}],{"rhoisl","rhoosl","chiXn1"}];
*)


(* 
(* dil *)
lablist=Join[{"filename","disl","dosl","Target function values"},Table["c"<>ToString[i],{i,1,Nsp}],{"rhoisl","rhoosl","rhodm","chiXn1"}];
*)

(* nat *)
lablist=Join[{"filename","disl","dosl","Target function values"},Table["c"<>ToString[i],{i,1,Nsp}],{"rhoisl","rhoosl","rhodm","chiXn1","chi"},Table["d"<>ToString[i],{i,2,Nst}]];


(*
lablist=Join[{"filename","disl","dosl","Chi2Red function values"},Table["c"<>ToString[i],{i,1,Nsp}],{"rhoisl","rhoosl","rhodm","chiXn1"}];
*)



Print[lablist];
Tpdata=DeriveTp[files,lablist[[4;;]]];

(* params derived from fit params *)
AppendTo[lablist,"dtot"];
Do[AppendTo[Tpdata[[i]],Tpdata[[i,1+1]]+Tpdata[[i,1+2]]],{i,1,Length[files]}];

(* ini, simply takes the cis (incl shells) and averages over i *)
AppendTo[lablist,"ici"];
Do[AppendTo[Tpdata[[i]],Sum[Tpdata[[i,4+j]]*j,{j,1,Nsp}]/Sum[Tpdata[[i,4+j]],{j,1,Nsp}]],{i,1,Length[files]}];

(* volume-averaged platelet thickness, ci refer to whole platelet thickness incl shells *)
AppendTo[lablist,"dci"];
Do[AppendTo[Tpdata[[i]],Sum[Tpdata[[i,4+j]]*(j*d001+2*(Tpdata[[i,1+1]]+Tpdata[[i,1+2]])),{j,1,Nsp}]/Sum[Tpdata[[i,4+j]],{j,1,Nsp}]],{i,1,Length[files]}];


(* nis *)
Do[
AppendTo[lablist,"n"<>ToString[j]];
Do[AppendTo[Tpdata[[i]],(Tpdata[[i,4+j]]/(j*d001+2*(Tpdata[[i,1+1]]+Tpdata[[i,1+2]])))/Sum[Tpdata[[i,4+k]]/(k*d001+2*(Tpdata[[i,1+1]]+Tpdata[[i,1+2]])),{k,1,Nsp}]],{i,1,Length[files]}];
,{j,1,Nsp}]

(* ini, simply takes the nis (incl shells) and averages over i *)
AppendTo[lablist,"ini"];
Do[AppendTo[Tpdata[[i]],Sum[j*(Tpdata[[i,4+j]]/(j*d001+2*(Tpdata[[i,1+1]]+Tpdata[[i,1+2]])))/Sum[Tpdata[[i,4+k]]/(k*d001+2*(Tpdata[[i,1+1]]+Tpdata[[i,1+2]])),{k,1,Nsp}],{j,1,Nsp}]],{i,1,Length[files]}];

(* number-averaged platelet thickness, ni refer to whole platelet thickness incl shells *)
AppendTo[lablist,"dni"];
Do[AppendTo[Tpdata[[i]],Sum[Tpdata[[i,4+j]]/Sum[Tpdata[[i,4+k]]/(k*d001+2*(Tpdata[[i,1+1]]+Tpdata[[i,1+2]])),{k,1,Nsp}],{j,1,Nsp}]],{i,1,Length[files]}];


AppendTo[lablist,"disl_rhoisl"];
Do[AppendTo[Tpdata[[i]],Tpdata[[i,1+1]]*Tpdata[[i,4+Nsp+1]]/10.0],{i,1,Length[files]}];

AppendTo[lablist,"dosl_rhoosl"];
Do[AppendTo[Tpdata[[i]],Tpdata[[i,1+2]]*Tpdata[[i,4+Nsp+2]]/10.0],{i,1,Length[files]}];

AppendTo[lablist,"disl_rhoisl_dosl_rhoosl"];
Do[AppendTo[Tpdata[[i]],Tpdata[[i,1+1]]*Tpdata[[i,4+Nsp+1]]/10.0+Tpdata[[i,1+2]]*Tpdata[[i,4+Nsp+2]]/10.0],{i,1,Length[files]}];




(* start analysis and plotting *)
Print[lablist];
pT[Tpdata[[All,All]],mindisl,maxdisl,ddisl,mindosl,maxdosl,ddosl,Nsp,lablist,mu2->{Trange,0.0},RhosPlotRange->UserDefinedRhosPlotRange,CisPlotRange->UserDefinedCisPlotRange,Quantiles->QuantileList,QuantilesSelectPlot->QuantilesPlotSelector];

,{j,1,Length[Trangelist]}];

,{i,1,Length[dirlist]}];






(* use always Exit[] *)
Exit[]
