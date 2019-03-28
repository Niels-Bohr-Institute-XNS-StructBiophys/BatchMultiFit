(* 
How-to run:

local (desktop) machine:
MathKernel -noprompt -run "<<run_BatchMultiFitStat_20190121_1to5dil.m" > run_BatchMultiFitStat_20190121_1to5dil.log &

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

(* all OSL_*00[5,6]/ incl SMALLER and LARGER, HUGE *)
dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_OSL_*00*","",Infinity],StringMatchQ[#,{_~~"*005",_~~"*006"}]&],DirectoryQ];

*)



Nsp=6;
mindisl=4;maxdisl=100;ddisl=4;
mindosl=4;maxdosl=100;ddosl=4;

(* SSS_7p5BC_1to5dil_OSL_HUGE_005_more and SSS_7p5BC_1to5dil_OSL_LARGER_005_more *)
dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_OSL_*00*","",Infinity],StringMatchQ[#,{_~~"*005_more"}]&],DirectoryQ];





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

dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_OSL_0*","",Infinity],StringMatchQ[#,{_~~"*011",_~~"*013",_~~"*015"}]&],DirectoryQ];
*)



Print[dirlist];

Trangelist={1.1,1.2,1.3,1.5};
UserDefinedRhosPlotRange={280,400};(*"Automatic";*)
UserDefinedCisPlotRange={0.0,0.55};(*"Automatic";*)


(* run *)

Do[(*dirlist*)

Do[(*Trangelist*)

Trange=Trangelist[[j]];

(* dir and log files *)
dir=dirlist[[i]];
If[StringTake[dir,-1]!="/",dir=dir<>"/"];
files=FileNames[dir<>"SSS*.log"];

(* derive default fit params from log-files, disl and dosl must not be passed to DeriveTp, choices for target fnc value: "Target function values", "Chi2Red function values", "LogdI function values" *)

lablist=Join[{"filename","disl","dosl","Target function values"},Table["c"<>ToString[i],{i,1,Nsp}],{"rhoisl","rhoosl","rhodm","chiXn1"}];

(*
if a param was fixed and the new BMF version was used in the fitting, it will find and process the fixed values as well, for old fits, exclude, but will crash at some point ...
lablist=Join[{"filename","disl","dosl","Target function values"},Table["c"<>ToString[i],{i,1,Nsp}],{"rhoisl","rhoosl","chiXn1"}];
*)

Print[lablist];
Tpdata=DeriveTp[files,lablist[[4;;]]];

(* params derived from fit params *)
AppendTo[lablist,"dtot"];
Do[AppendTo[Tpdata[[i]],Tpdata[[i,1+1]]+Tpdata[[i,1+2]]],{i,1,Length[files]}];

AppendTo[lablist,"ici"];
Do[AppendTo[Tpdata[[i]],Sum[Tpdata[[i,4+j]]*j,{j,1,Nsp}]/Sum[Tpdata[[i,4+j]],{j,1,Nsp}]],{i,1,Length[files]}];

AppendTo[lablist,"disl_rhoisl"];
Do[AppendTo[Tpdata[[i]],Tpdata[[i,1+1]]*Tpdata[[i,4+Nsp+1]]/10.0],{i,1,Length[files]}];

AppendTo[lablist,"dosl_rhoosl"];
Do[AppendTo[Tpdata[[i]],Tpdata[[i,1+2]]*Tpdata[[i,4+Nsp+2]]/10.0],{i,1,Length[files]}];

AppendTo[lablist,"disl_rhoisl_dosl_rhoosl"];
Do[AppendTo[Tpdata[[i]],Tpdata[[i,1+1]]*Tpdata[[i,4+Nsp+1]]/10.0+Tpdata[[i,1+2]]*Tpdata[[i,4+Nsp+2]]/10.0],{i,1,Length[files]}];

(* start analysis and plotting *)
Print[lablist];
pT[Tpdata[[All,All]],mindisl,maxdisl,ddisl,mindosl,maxdosl,ddosl,Nsp,lablist,mu2->{Trange,0.0},RhosPlotRange->UserDefinedRhosPlotRange,CisPlotRange->UserDefinedCisPlotRange];

,{j,1,Length[Trangelist]}];

,{i,1,Length[dirlist]}];






(* use always Exit[] *)
Exit[]
