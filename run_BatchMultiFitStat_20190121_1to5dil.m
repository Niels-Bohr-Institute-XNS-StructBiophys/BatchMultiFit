(* 

How-to run:

local (desktop) machine:
MathKernel -noprompt -run "<<run_BatchMultiFitStat_20190121_1to5dil.m" > run_BatchMultiFitStat_20190121_1to5dil.log &

on a (headless) server (where no X is running):
screen -d -m xvfb-run MathKernel -noprompt -run "<<run_BatchMultiFitStat_20190121_1to5dil.m" > run_BatchMultiFitStat_20190121_1to5dil.log

Note: package xvfb-run must be installed
*)


(* Load BatchMultiFitStat program *)
(*
SetDirectory["/home/martins/projects/BatchMultiFit"];

Get["/home/martins/projects/BatchMultiFit/BatchMultiFitStat.m"];
*)

Get["BatchMultiFitStat.m"];



(* simulation params for cis, disl and dosl *)
(*
Nsp=6;
mindisl=4;maxdisl=20;ddisl=2;
mindosl=4;maxdosl=20;ddosl=2;

dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_00*","",Infinity],StringMatchQ[#,{_~~"*003*",_~~"*004*"}]&],DirectoryQ];
Print[dirlist];
*)



(* simulation params for cis, disl and dosl *)
(*
Nsp=6;
mindisl=4;maxdisl=144;ddisl=4;
mindosl=4;maxdosl=144;ddosl=4;

dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_00*","",Infinity],StringMatchQ[#,{_~~"*005*",_~~"*006*"}]&],DirectoryQ];
Print[dirlist];
*)



(* simulation params for cis, disl and dosl *)

Nsp=6;
mindisl=4;maxdisl=144;ddisl=4;
mindosl=4;maxdosl=144;ddosl=4;

dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_OSL_00*","",Infinity],StringMatchQ[#,{_~~"*005*",_~~"*006*"}]&],DirectoryQ];
(* dirlist=Select[Select[FileNames["MathematicaOut/SSS_*BC_1to5dil_OSL_00*","",Infinity],StringMatchQ[#,{_~~"*007*"}]&],DirectoryQ]; *)
Print[dirlist];




(* run *)
Do[

(* dir and log files *)
dir=dirlist[[i]];
If[StringTake[dir,-1]!="/",dir=dir<>"/"];
files=FileNames[dir<>"SSS*.log"];

(* default fit params *)
(* Choices: "Target function values", "Chi2Red function values", "LogdI function values" *)
lablist=Join[{"disl","dosl","Target function values"},Table["c"<>ToString[i],{i,1,Nsp}],{"rhoisl","rhoosl","rhodm","chiXn1"}];
(*lablist=Join[{"disl","dosl","Target function values"},Table["c"<>ToString[i],{i,1,Nsp}],{"rhoisl","rhoosl","chiXn1"}];*)
Tpdata=DeriveTp[files,lablist];

(* params derived from fit params *)
AppendTo[lablist,"dtot"];
Do[AppendTo[Tpdata[[i]],Tpdata[[i,1+1]]/10.0+Tpdata[[i,1+2]]/10.0,{j,1,Nsp}]],{i,1,Length[files]}];

AppendTo[lablist,"ici"];
Do[AppendTo[Tpdata[[i]],Sum[Tpdata[[i,4+j]]*j,{j,1,Nsp}]/Sum[Tpdata[[i,4+j]],{j,1,Nsp}]],{i,1,Length[files]}];

AppendTo[lablist,"disl_rhoisl"];
Do[AppendTo[Tpdata[[i]],Tpdata[[i,1+1]]*Tpdata[[i,4+Nsp+1]]/10.0],{i,1,Length[files]}];

AppendTo[lablist,"dosl_rhoosl"];
Do[AppendTo[Tpdata[[i]],Tpdata[[i,1+2]]*Tpdata[[i,4+Nsp+2]]/10.0],{i,1,Length[files]}];

AppendTo[lablist,"disl_rhoisl_dosl_rhoosl"];
Do[AppendTo[Tpdata[[i]],Tpdata[[i,1+1]]*Tpdata[[i,4+Nsp+1]]/10.0+Tpdata[[i,1+2]]*Tpdata[[i,4+Nsp+2]]/10.0],{i,1,Length[files]}];

(* start analysis and plotting *)
pT[Tpdata[[All,All]],mindisl,maxdisl,ddisl,mindosl,maxdosl,ddosl,Nsp,lablist];

,{i,1,Length[dirlist]}]




(* use always Exit[] *)
Exit[]
