(* Change option DisplayFunction from its default $DisplayFunction to Identity does not prevent starting the frontend (renderer) *)
SetOptions[ListPlot,DisplayFunction->Identity];
SetOptions[ListLogPlot,DisplayFunction->Identity];
SetOptions[ListLogLogPlot,DisplayFunction->Identity];
SetOptions[GraphicsGrid,DisplayFunction->Identity];
Needs["ErrorBarPlots`"] 
SetOptions[ErrorListPlot,DisplayFunction->Identity];
DistributeDefinitions[ErrorListPlot];
(* Do not use ParallelNeeds["ErrorBarPlots`"], use DistributeDefinitions *)
SetDirectory["/home/martins/projects/BatchMultiFit"];

Get["ErrorBarLogPlots.m"];
(*SetOptions[ErrorListLogLogPlot,DisplayFunction->Identity];*)
DistributeDefinitions[ErrorListLogLogPlot];
(* Do not use ParallelEvaluate[] with Get[] use DistributeDefinitions *)
SetOptions[BarChart,DisplayFunction->Identity];
SetDirectory[];


(*
TODO:
-unknown bug, if not at least one #-line, it will throw warning messages at least
INFO:
- files may contain lines starting with # and empty lines as well
- expect 2-4 columns, error exit if not
- allowed column input formats:
-- s, I(s)
-- s, I(s), dI(s)
-- s, I(s), dI(s), ds(s)
- internal format is however s, I(s), ds(s), dI(s) !
- if only 2 columns fill 3rd column with 0.0
- if only 2-3 columns fill 4th column with 0.0
- check if dI is min. 1% of I
*)
Clear[loadexp]
loadexp[file0_,PrintFlag0_:False,PrintFunc0_:Print,smin0_:0,smax0_:Infinity]:=Module[{file=file0,PrintFlag=PrintFlag0,PrintFunc=PrintFunc0,smin=smin0,smax=smax0,exp,dummy,dummy2,th},
exp={};
th=0.01; (* threshold for dI/I *)
Do[
If[PrintFlag,PrintFunc@@{"Load file "<>file[[i]]};];
dummy=Import[file[[i]],"Table"];
(* ignore all lines starting with # *)
dummy=Drop[dummy[[Max[Position[dummy,"#"][[All,1]]]+1;;,All]],-1];
(* remove empty list elements stemming from empty lines *)
dummy=Select[dummy,#!={}&];
(* apply s-filter, usually all points are read *)
dummy=Select[dummy,(#[[1]]>=smin&&#[[1]]<=smax)&];
If[Dimensions[dummy][[2]]>4||Dimensions[dummy][[2]]<2,Print["File "<>ToString[file[[i]]]<>" has "<>Dimensions[dummy][[2]]<>" columns. Expected 2-4. Exit."];Exit[];];
If[PrintFlag,PrintFunc@@{"File "<>ToString[file[[i]]]<>" has "<>ToString[Dimensions[dummy][[2]]]<>" columns"};];
If[PrintFlag,PrintFunc@@{"Selected "<>ToString[Length[dummy]]<>" datapoints between s=["<>ToString[smin]<>","<>ToString[smax]<>"]"};];
(* drop non positive datapoints  *)
dummy=Select[dummy,#[[2]]>0&];
If[PrintFlag,PrintFunc@@{"Selected "<>ToString[Length[dummy]]<>" positive datapoints from that"};];
(* append missing dI and ds error if only 2 columns *)
(* If[Dimensions[dummy][[2]]==2,dummy=MapThread[Append,{dummy,0.01*dummy[[All,2]]}];]; *)
If[Dimensions[dummy][[2]]==2,dummy=ArrayFlatten[{{dummy,0.0,0.0}}];];
(* append missing ds error if only 3 columns *)
If[Dimensions[dummy][[2]]==3,dummy=ArrayFlatten[{{dummy,0.0}}];];
(* set a minimum for dI in 3rd column *)
If[PrintFlag,PrintFunc@@{"Reset dI to dI="<>ToString[th]<>"*I for "<>ToString[Length[Select[dummy,#[[3]]<th*#[[2]]&]]]<>" datapoints"};];
dummy=If[#[[3]]<th*#[[2]],{#[[1]],#[[2]],th*#[[2]],#[[4]]},#]&/@dummy;
(* swap 3rd and 4th colum for internal column format *)
If[PrintFlag,PrintFunc@@{"Swapped internally 3rd and 4th column"};];
dummy2=dummy[[All,3]];dummy[[All,3]]=dummy[[All,4]];dummy[[All,4]]=dummy2;
AppendTo[exp,dummy];
,{i,1,Length[file]}];
exp
];



(* for SANS, theoretical wavelength smearing for medium and high-Q range; ds = s*(\Delta\Lambda/\Lambda)/(2*Sqrt[2*ln(2)]), ln(2)==Log[2] *)
Clear[dstheo]
dstheo[s_,dlambda_]:=s*dlambda/(2*Sqrt[2*Log[2]]);



Clear[smearfile];
smearfile[file0_,Smear0_:{0,0.0}]:=Module[{file=file0,Smear=Smear0,s,ds,y,yy,sMin,sMax,dummy,SmearMode,SmearLambdaRes,f,Nds,data},
(* definitions *)
SmearMode=Smear[[1]];
SmearLambdaRes=If[SmearMode==1,Smear[[2]],0.0];
Nds=If[SmearMode>0,3,0];
(* import file *)
data=Import[file,"Table"];
data=data[[Max[{Max[Position[data,"#"][[All,1]]],0}]+1;;,All]];
s=data[[All,1]];
y=data[[All,2]];
(* interpolate to f *)
dummy=Transpose[{s,y}];
f=Interpolation[dummy];
(* SmearMode=0 -> no smearing, =1 -> smearing with theoretical values, =2 -> smearing with experimental ds if provided in 3rd column *)
If[SmearMode==2&&Dimensions[data][[2]]<3,Print["For SmearMode==2 the experimental ds must be provided in the 3rd column. Exit."];Exit[];];
(* Integrate within Nds*Sigma interval *)
If[SmearMode>0,
yy=y;sMin=Min[s];sMax=Max[s];
(* setup ds for either SmearMode 1 or 2 *)
If[SmearMode==1,ds=dstheo[s,SmearLambdaRes];,ds=data[[All,3]];];
(* convolute, skip points too close to sMin and sMax *)
Do[
If[(s[[i]]-Nds*ds[[i]])>sMin&&(s[[i]]+Nds*ds[[i]])<sMax,
yy[[i]]=Total[1/(Sqrt[2*Pi]*ds[[i]])*Exp[-((#-s[[i]])^2/(2*(ds[[i]])^2))]*(f@#)&/@Range[s[[i]]-Nds*ds[[i]],s[[i]]+Nds*ds[[i]],2*Nds*ds[[i]]/100]]/Total[1/(Sqrt[2*Pi]*ds[[i]])*Exp[-((#-s[[i]])^2/(2*(ds[[i]])^2))]&/@Range[s[[i]]-Nds*ds[[i]],s[[i]]+Nds*ds[[i]],2*Nds*ds[[i]]/100]];
];,
{i,1,Length[s]}];
dummy=Transpose[{s,yy,ds}];
];
Export[file<>"_smeared",dummy,"Table"];
];



(* 
Compile[] is not really helpful for loadY

For RetVecIF0==True, the Y-files are interpolated to experimental s-grid, i.e. a vector of Y at the experimental s is returned
For RetVecIF0==False, the Y-files are interpolated and an interpolation function for Y is returned

smear optionally SANS data, SmearMode=0 -> no smearing, =1 -> smearing with theoretical values, =2 -> smearing with experimental ds from exp
*)
Clear[loadY]
loadY[RetVecIF0_,basefile0_,exp0_,Xnmode0_,conc0_,Smear0_:{0,0.0},NMaxsp0_:25,NMaxst0_:25,PrintFlag0_:False,PrintFunc0_:Print]:=Module[{basefile=basefile0,exp=exp0,Xnmode=Xnmode0,NMaxsp=NMaxsp0,NMaxst=NMaxst0,Smear=Smear0,conc=conc0,RetVecIF=RetVecIF0,PrintFlag=PrintFlag0,PrintFunc=PrintFunc0,data,dummy,s,file,y,SmearMode,SmearLambdaRes,ds,dsexp,Nds,sMax,sMin,yy,fsp,fst,Nsp,Nst,Nspst,spstmode,ll},
If[Xnmode!="X"&&Xnmode!="n",Print["Unknown mode "<>ToString[Xnmode]<>". Exit."];Exit[];];
(* smearing option for SANS curves *)
SmearMode=Smear[[1]];
SmearLambdaRes=If[SmearMode==1,Smear[[2]],0.0];
Nds=If[SmearMode>0,3,0];
If[SmearMode==2,dsexp=Interpolation[exp[[All,{1,3}]]];];
If[PrintFlag,
PrintFunc@@{"SmearMode = "<>ToString[SmearMode]};
PrintFunc@@{"SmearLambdaRes = "<>ToString[SmearLambdaRes]};
PrintFunc@@{"Nds = "<>ToString[Nds]};
];
(* detect amount of sp and st files *)
Nsp=0;Nst=0;
If[NMaxsp>0,Do[file=basefile<>"_Y_"<>Xnmode<>"_sp_"<>If[l<10,"0",""]<>ToString[l]<>".dat";If[FileExistsQ[file],Nsp+=1;],{l,1,NMaxsp}];];
If[NMaxst>0,Do[file=basefile<>"_Y_"<>Xnmode<>"_st_"<>If[l<10,"0",""]<>ToString[l]<>".dat";If[FileExistsQ[file],Nst+=1;],{l,1,NMaxst}];];
If[Nsp+Nst==0,Print["Error: No Files with pattern "<>basefile<>"_Y_"<>Xnmode<>"_*"<>" found. Exit."];Exit[];];
(* prepare sp/st data containers for both options of RetVecIF *)
If[NMaxsp>0,fsp=Table[Identity,{l,1,Nsp},{p,1,10}];];
If[NMaxst>0,fst=Table[Identity,{l,1,Nst},{p,1,10}];];
(* write parameters to logfile *)
If[PrintFlag,
PrintFunc@@{"Nsp = "<>ToString[Nsp]};
PrintFunc@@{"Nst = "<>ToString[Nst]};
PrintFunc@@{"conc = "<>ToString[conc]};
];
(* load sp/st files, works also for Nsp=0 or Nst=0, k==1->sp, k==2->st, ll index for filenames *)
Do[If[k==1,spstmode="sp";Nspst=Nsp;,spstmode="st";Nspst=Nst;]
Do[
(* sp or st *)
ll=l+(k-1);
file=basefile<>"_Y_"<>Xnmode<>"_"<>spstmode<>"_"<>If[ll<10,"0",""]<>ToString[ll]<>".dat";
If[PrintFlag,PrintFunc@@{file};];
data=Import[file,"Table"];
data=data[[Max[{Max[Position[data,"#"][[All,1]]],0}]+1;;,All]];
Do[(* set up interpolation without smearing at first *)
s=data[[All,1]];
y=conc*100.0*data[[All,p+1]];
dummy=Transpose[{s,y}];
If[k==1,fsp[[l,p]]=Interpolation[dummy];,fst[[l,p]]=Interpolation[dummy];];
(* smear optionally SANS data, SmearMode=0 -> no smearing, =1 -> smearing with theoretical values, =2 -> smearing with experimental ds from exp *)
If[SmearMode>0,
(* Integrate within Nds*Sigma interval *)
yy=y;sMin=Min[s];sMax=Max[s];
(* setup ds *)
If[SmearMode==1,
ds=dstheo[s,SmearLambdaRes];,
(*Extrapolate for SmearMode==2 if s_exp is outside of range*)
ds=Table[Which[s[[i]]>Max[exp[[All,1]]],Max[exp[[All,1]]],s[[i]]<Min[exp[[All,1]]],Min[exp[[All,1]]],True,s[[i]]],{i,1,Length[s]}];
ds=dsexp@ds;
];
(* convolute at each s *)
Do[
If[k==1,(* sp -> fsp *)
If[(s[[i]]-Nds*ds[[i]])>sMin&&(s[[i]]+Nds*ds[[i]])<sMax,yy[[i]]=Total[1/(Sqrt[2*Pi]*ds[[i]])*Exp[-((#-s[[i]])^2/(2*(ds[[i]])^2))]*(fsp[[l,p]]@#)&/@Range[s[[i]]-Nds*ds[[i]],s[[i]]+Nds*ds[[i]],2*Nds*ds[[i]]/100]]/Total[1/(Sqrt[2*Pi]*ds[[i]])*Exp[-((#-s[[i]])^2/(2*(ds[[i]])^2))]&/@Range[s[[i]]-Nds*ds[[i]],s[[i]]+Nds*ds[[i]],2*Nds*ds[[i]]/100]];];,
(* st -> fst *)
If[(s[[i]]-Nds*ds[[i]])>sMin&&(s[[i]]+Nds*ds[[i]])<sMax,yy[[i]]=Total[1/(Sqrt[2*Pi]*ds[[i]])*Exp[-((#-s[[i]])^2/(2*(ds[[i]])^2))]*(fst[[l,p]]@#)&/@Range[s[[i]]-Nds*ds[[i]],s[[i]]+Nds*ds[[i]],2*Nds*ds[[i]]/100]]/Total[1/(Sqrt[2*Pi]*ds[[i]])*Exp[-((#-s[[i]])^2/(2*(ds[[i]])^2))]&/@Range[s[[i]]-Nds*ds[[i]],s[[i]]+Nds*ds[[i]],2*Nds*ds[[i]]/100]];];
];,{i,1,Length[s]}];
dummy=Transpose[{s,yy}];
(* assign interpolation of dummy either to fsp or fst *)
If[k==1,fsp[[l,p]]=Interpolation[dummy];,fst[[l,p]]=Interpolation[dummy];];
];
(* return vector at exp s-points for RetVecIF==True instead of the interpolation functions *)
If[RetVecIF,If[k==1,fsp[[l,p]]=fsp[[l,p]]/@exp[[All,1]];,fst[[l,p]]=fst[[l,p]]/@exp[[All,1]];];];
,{p,1,10}];
,{l,1,Nspst}];
,{k,1,2}];
(* return *)
{Nsp,Nst,fsp,fst}
];



Clear[createset]
(* creates sets set from exp. Determines also number of points in each data set and computes just for information sum of intensities in the selected range *)
createset[exp0_,smin0_,smax0_,PrintFlag0_:False,PrintFunc0_:Print]:=Module[{exp=exp0,smin=smin0,smax=smax0,PrintFlag=PrintFlag0,PrintFunc=PrintFunc0,set,Lengthset,Normset},
set=Select[exp,(#[[1]]>=smin&&#[[1]]<=smax)&];Lengthset=Length[set];Normset=Norm[set[[All,2]],1];
If[PrintFlag,
PrintFunc@@{"Number of points in set: "<>ToString[Lengthset]};
PrintFunc@@{"Norm of points in set: "<>ToString[Normset]};
];(* return *)
set
];



Clear[T]
(*
  - with scaling function scf e.g. Log or Identity,
  - in case of Log, the Residuals resemble those of Hub / Henriques+Skepoe papers [ log(I_exp) - log( ycohscf * I_mod + a ) ]^2
  - individual scaling factors for coherent y contributions (ycohscf) for each set are possible (e.g. if concentration or abs units are not exactly the same)
  - individual scaling factors for residuals (Tscf) of each set are possible
  - respect different intensities and number of points between different data sets by Normyexp, which includes both effects
  - c, d, rho / sld etc are derived from par-list
  - for X and n suitable
  - s can be list or point
  - it might be a good idea to try Compile[] for T
  - fsp, fst and Tscf must be lists of same length as set
  - Length[p] must be Nst+Nsp+4*Length[set]
*)
T[p0_,Nsp0_,Nst0_,set0_,fsp0_,fst0_,Tscf0_,scf0_,smin0_:0,smax0_:Infinity]:=Module[{p=p0,Nsp=Nsp0,Nst=Nst0,set=set0,fsp=fsp0,fst=fst0,Tscf=Tscf0,scf=scf0,smin=smin0,smax=smax0,c,d,rho,drho,ddrho,a,count,Nset,s,y,ycohscf,yexp,Normyexp,f},
(* adapt depth of input arguments if necessary *)
(* Depth == # of indices + 1 *)
(* set: Dim={Nset}, Depth=4; fsp/fst: Dim={Nset,Nsp/Nst,10}, Depth=7; Tscf: Dim={2}, Depth=2 *)
(* set[[i]]: Dim={L_s,L_I}, Depth=3; fsp/fst: Dim={Nsp/Nst,10}, Depth=6; Tscf: Dim={}, Depth=1 *)
If[Length[Dimensions[set]]==2,set={set};];
If[Length[Dimensions[fsp]]==2,fsp={fsp};];
If[Length[Dimensions[fst]]==2,fst={fst};];
If[Length[Dimensions[Tscf]]==0,Tscf={Tscf};];
Nset=Length[set];
count=0;
(* get common c's and d's *)
If[Nsp>0,c=Abs[p[[count+1;;count+Nsp]]];count+=Nsp;];
If[Nst>0,d=Abs[p[[count+1;;count+Nst]]];count+=Nst;];
(* target function value f that will be minimized *)
f=0;
Do[
rho=p[[count+1;;count+3]];
a=p[[count+4]];
ycohscf=p[[Nsp+Nst+4*Nset+i]];
count+=4;
drho={rho[[1]],rho[[2]]-rho[[1]],rho[[3]]-rho[[2]]};
ddrho=ConstantArray[0,9];
ddrho[[1]]=(drho[[3]])^2;
ddrho[[2]]=(drho[[2]])^2;
ddrho[[3]]=(drho[[1]])^2;
ddrho[[4]]=drho[[3]]*drho[[2]];
ddrho[[5]]=drho[[3]]*drho[[1]];
ddrho[[6]]=drho[[2]]*drho[[1]];
ddrho[[7]]=drho[[3]];
ddrho[[8]]=drho[[2]];
ddrho[[9]]=drho[[1]];
s=Select[set[[i]][[All,1]],smin<#<smax&];
yexp=Select[set[[i]],smin<#[[1]]<smax&][[All,2]];
y=ConstantArray[0,Length[s]];
Normyexp=Norm[yexp,1];
If[Nsp>0,Do[y+=c[[l]]*(fsp[[i]][[l,1]]/@s+Sum[ddrho[[p]]*fsp[[i]][[l,p+1]]/@s,{p,1,9}]);,{l,1,Nsp}];];
If[Nst>0,Do[y+=d[[l]]*(fst[[i]][[l,1]]/@s+Sum[ddrho[[p]]*fst[[i]][[l,p+1]]/@s,{p,1,9}]);,{l,1,Nst}];];
y*=ycohscf;
y+=a;
f+=Tscf[[i]]*Norm[scf/@(y/Normyexp)-scf/@(yexp/Normyexp),2];
,{i,1,Nset}];
f];


(* scf can be "red" to obtain reduced Chi2 1/(n-#p) *)
(* 
   currently all parameters for one dataset are assumed to be NOT fixed, i.e. no check is applied if they are fixed

   #p=Nsp+Nst+3+1+1 (3x SLD, bkg, scale chiXn) 
*)
Chi2[p0_,Nsp0_,Nst0_,set0_,fsp0_,fst0_,Tscf0_,scf0_,smin0_:0,smax0_:Infinity]:=Module[{p=p0,Nsp=Nsp0,Nst=Nst0,set=set0,fsp=fsp0,fst=fst0,Tscf=Tscf0,scf=scf0,smin=smin0,smax=smax0,c,d,rho,drho,ddrho,a,count,Nset,s,y,ycohscf,yexp,sigma,red,f},
(* adapt depth of input arguments if necessary *)
(* Depth == # of indices + 1 *)
(* set: Dim={Nset}, Depth=4; fsp/fst: Dim={Nset,Nsp/Nst,10}, Depth=7; Tscf: Dim={2}, Depth=2 *)
(* set[[i]]: Dim={L_s,L_I}, Depth=3; fsp/fst: Dim={Nsp/Nst,10}, Depth=6; Tscf: Dim={}, Depth=1 *)
If[Length[Dimensions[set]]==2,set={set};];
If[Length[Dimensions[fsp]]==2,fsp={fsp};];
If[Length[Dimensions[fst]]==2,fst={fst};];
If[Length[Dimensions[Tscf]]==0,Tscf={Tscf};];
Nset=Length[set];
count=0;
(* get common c's and d's *)
If[Nsp>0,c=Abs[p[[count+1;;count+Nsp]]];count+=Nsp;];
If[Nst>0,d=Abs[p[[count+1;;count+Nst]]];count+=Nst;];
(* target function value f that will be minimized *)
f=0;
Do[
rho=p[[count+1;;count+3]];
a=p[[count+4]];
ycohscf=p[[Nsp+Nst+4*Nset+i]];
count+=4;
drho={rho[[1]],rho[[2]]-rho[[1]],rho[[3]]-rho[[2]]};
ddrho=ConstantArray[0,9];
ddrho[[1]]=(drho[[3]])^2;
ddrho[[2]]=(drho[[2]])^2;
ddrho[[3]]=(drho[[1]])^2;
ddrho[[4]]=drho[[3]]*drho[[2]];
ddrho[[5]]=drho[[3]]*drho[[1]];
ddrho[[6]]=drho[[2]]*drho[[1]];
ddrho[[7]]=drho[[3]];
ddrho[[8]]=drho[[2]];
ddrho[[9]]=drho[[1]];
s=Select[set[[i]][[All,1]],smin<#<smax&];
yexp=Select[set[[i]],smin<#[[1]]<smax&][[All,2]];
sigma=Select[set[[i]],smin<#[[1]]<smax&][[All,4]];
y=ConstantArray[0,Length[s]];
If[Nsp>0,Do[y+=c[[l]]*(fsp[[i]][[l,1]]/@s+Sum[ddrho[[p]]*fsp[[i]][[l,p+1]]/@s,{p,1,9}]);,{l,1,Nsp}];];
If[Nst>0,Do[y+=d[[l]]*(fst[[i]][[l,1]]/@s+Sum[ddrho[[p]]*fst[[i]][[l,p+1]]/@s,{p,1,9}]);,{l,1,Nst}];];
y*=ycohscf;
y+=a;
red=If[ToString[scf]=="red",1.0/(Length[s]-Nsp-Nst-3-1-1),1.0];
f+=Tscf[[i]]*red*Norm[(y-yexp)/sigma,2]^2;
,{i,1,Nset}];
f];



Clear[Tv01]
Tv01[p0_,Nsp0_,Nst0_,set0_,fsp0_,fst0_,Tscf0_,scf0_:Log,smin0_:0,smax0_:Infinity]:=Module[{p=p0,Nsp=Nsp0,Nst=Nst0,set=set0,fsp=fsp0,fst=fst0,Tscf=Tscf0,scf=scf0,smin=smin0,smax=smax0,c,d,rho,drho,ddrho,a,count,Nset,s,y,ys,ycohscf,yexp,f},
(* adapt depth of input arguments if necessary *)
(* Depth == # of indices + 1 *)
(* set: Dim={Nset}, Depth=4; fsp/fst: Dim={Nset,Nsp/Nst,10}, Depth=5; Tscf: Dim={2}, Depth=2 *)
(* set[[i]]: Dim={L_s,L_I}, Depth=3; fsp/fst: Dim={Nsp/Nst,10,L_I}, Depth=4; Tscf: Dim={}, Depth=1 *)
If[Length[Dimensions[set]]==2,set={set};];(* or If[Depth[set]-1==2,...]; *)
If[Depth[fsp]-1==3,fsp={fsp};];
If[Depth[fst]-1==3,fst={fst};];
If[Length[Dimensions[Tscf]]==0,Tscf={Tscf};];(* or If[Depth[Tscf]-1==0,...]; *)
Nset=Length[set];
count=0;
(*get common c's and d's*)
If[Nsp>0,c=Abs[p[[count+1;;count+Nsp]]];count+=Nsp;];
If[Nst>0,d=Abs[p[[count+1;;count+Nst]]];count+=Nst;];
(*target function value f that will be minimized*)
f=0.0;
Do[
rho=p[[count+1;;count+3]];
a=p[[count+4]];
ycohscf=p[[Nsp+Nst+4*Nset+i]];
count+=4;
drho={rho[[1]],rho[[2]]-rho[[1]],rho[[3]]-rho[[2]]};
ddrho=Table[0.0,{i,1,10}];
ddrho[[1]]=1.0;
ddrho[[2]]=(drho[[3]])^2;ddrho[[3]]=(drho[[2]])^2;ddrho[[4]]=(drho[[1]])^2;
ddrho[[5]]=drho[[3]]*drho[[2]];ddrho[[6]]=drho[[3]]*drho[[1]];ddrho[[7]]=drho[[2]]*drho[[1]];
ddrho[[8]]=drho[[3]];ddrho[[9]]=drho[[2]];ddrho[[10]]=drho[[1]];
s=set[[i]][[All,1]];
y=0.0*s;
If[Nsp>0,Do[Do[y+=c[[l]]*ddrho[[p]]*fsp[[i]][[l,p]],{p,1,10}];,{l,1,Nsp}];];
If[Nst>0,Do[Do[y+=d[[l]]*ddrho[[p]]*fst[[i]][[l,p]],{p,1,10}];,{l,1,Nst}];];
y*=ycohscf;
y+=a;
(* select s-range *)
yexp=Select[set[[i]],smin<#[[1]]<smax&][[All,2]];
ys=Transpose[{s,y}];
y=Select[ys,smin<#[[1]]<smax&][[All,2]];
(* update f *)
f+=Tscf[[i]]*Norm[scf/@(y/yexp),2];
,{i,1,Nset}];
f];


Clear[F]
(* 
  - c, d, rho / sld etc are derived from par-list
  - for X and n suitable
  - s can be list or point
  - individual scaling factors for coherent y contributions (ycohscf) for each set are possible (e.g. if concentration or abs units are not exactly the same)
  - it might be a good idea to try Compile[] for F
  - only one set -> p, fsp, fst, s only for this set !
  - Length[p] must be Nst+Nsp+5
*)
F[p0_,fsp0_,fst0_,Nsp0_,Nst0_,s0_]:=Module[{p=p0,fsp=fsp0,fst=fst0,Nsp=Nsp0,Nst=Nst0,s=s0,c,d,rho,drho,ddrho,a,count,y,ycohscf},
count=0;
(* get c's, d's etc from p *)
If[Nsp>0,c=Abs[p[[count+1;;count+Nsp]]];count+=Nsp;];
If[Nst>0,d=Abs[p[[count+1;;count+Nst]]];count+=Nst;];
rho=p[[count+1;;count+3]];
a=p[[count+4]];
ycohscf=p[[count+5]];
drho={rho[[1]],rho[[2]]-rho[[1]],rho[[3]]-rho[[2]]};
ddrho=ConstantArray[0,9];
ddrho[[1]]=(drho[[3]])^2;
ddrho[[2]]=(drho[[2]])^2;
ddrho[[3]]=(drho[[1]])^2;
ddrho[[4]]=drho[[3]]*drho[[2]];
ddrho[[5]]=drho[[3]]*drho[[1]];
ddrho[[6]]=drho[[2]]*drho[[1]];
ddrho[[7]]=drho[[3]];
ddrho[[8]]=drho[[2]];
ddrho[[9]]=drho[[1]];
y=ConstantArray[0,Length[s]];
If[Nsp>0,Do[y+=c[[l]]*(fsp[[l,1]]/@s+Sum[ddrho[[p]]*fsp[[l,p+1]]/@s,{p,1,9}]);,{l,1,Nsp}];];
If[Nst>0,Do[y+=d[[l]]*(fst[[l,1]]/@s+Sum[ddrho[[p]]*fst[[l,p+1]]/@s,{p,1,9}]);,{l,1,Nst}];];
y*=ycohscf;
y+=a;
y];


Clear[Fv01]
Fv01[p0_,fsp0_,fst0_,Nsp0_,Nst0_,s0_]:=Module[{p=p0,fsp=fsp0,fst=fst0,Nsp=Nsp0,Nst=Nst0,s=s0,c,d,rho,drho,ddrho,a,count,y,ycohscf},
count=0;
(*get common c's and d's*)
c=Table[0.0,{i,1,Nsp}];
d=Table[0.0,{i,1,Nst}];
If[Nsp>0,c=Abs[p[[count+1;;count+Nsp]]];count+=Nsp;];
If[Nst>0,d=Abs[p[[count+1;;count+Nst]]];count+=Nst;];
(* get other parameters *)
rho=p[[count+1;;count+3]];a=p[[count+4]];
ycohscf=p[[count+5]];
drho={rho[[1]],rho[[2]]-rho[[1]],rho[[3]]-rho[[2]]};
ddrho=Table[0.0,{i,1,10}];
ddrho[[1]]=1.0;
ddrho[[2]]=(drho[[3]])^2.0;ddrho[[3]]=(drho[[2]])^2.0;ddrho[[4]]=(drho[[1]])^2.0;
ddrho[[5]]=drho[[3]]*drho[[2]];ddrho[[6]]=drho[[3]]*drho[[1]];ddrho[[7]]=drho[[2]]*drho[[1]];
ddrho[[8]]=drho[[3]];ddrho[[9]]=drho[[2]];ddrho[[10]]=drho[[1]];
y=0.0*s;
If[Nsp>0,Do[Do[y+=c[[l]]*ddrho[[p]]*fsp[[l,p]],{p,1,10}];,{l,1,Nsp}];];
If[Nst>0,Do[Do[y+=d[[l]]*ddrho[[p]]*fst[[l,p]],{p,1,10}];,{l,1,Nst}];];
y*=ycohscf;
y+=a;
y];


Clear[Num2Str]
Num2Str[x0_,p0_Integer,n0_Integer,padright0_String]:=Module[{x=x0,p=p0,n=n0,padright=padright0},ExportString[ToString@NumberForm[x,{p,n},NumberPadding->{"",padright},NumberFormat->(If[#3==="",#1,If[StringFreeQ[#3,"-"],Row[{#1,"E","+"<>#3}],Row[{#1,"E",#3}]]]&)],"Table"]];


(* maybe using OptionsValues for BatchMultiFit[...] in the future would be better for realizing optional arguments !!! *)
(* use "Automatic" for FitMethod in case of constrained local optimization with FindMinimum as FitFunc, "LevenbergMarquardt" and others work only for uncontrained problems *)

Clear[BatchMultiFit]
BatchMultiFit[OutDir0_,Xnmode0_,expfileconc0_,YFileDir0_,YFileListLocal0_,Nmaxsp0_,Nmaxst0_,FitFunc0_,FitMethod0_,Fitsmin0_,Fitsmax0_,FitMaxIt0_,FitTarF0_,ParStart0_,PlRange0_,plsc0_:1.0,Ymode0_:1,AddConstraints0_:{},Smear0_:{0,0.0},Tscf0_:1.0,ycohscf0_:{False,1.0,"1.0<=#<=1.0"},LicoConstr0_:{"","==1.0"},ExportFlag0_:False,PlotFlag0_:False,cdConstr0_:{False,{"chi",True,0.0(*,Constraint*)}},ow0_:False]:=Module[{OutDir=OutDir0,Xnmode=Xnmode0,expfileconc=expfileconc0,YFileDir=YFileDir0,YFileListLocal=YFileListLocal0,Nmaxsp=Nmaxsp0,Nmaxst=Nmaxst0,FitFunc=FitFunc0,FitMethod=FitMethod0,Fitsmin=Fitsmin0,Fitsmax=Fitsmax0,FitMaxIt=FitMaxIt0,FitTarF=FitTarF0,ParStart=ParStart0,PlRange=PlRange0,plsc=plsc0,Ymode=Ymode0,AddConstraints=AddConstraints0,Smear=Smear0,Tscf=Tscf0,ycohscf=ycohscf0,LicoConstr=LicoConstr0,LicoConstr2Num,ExportFlag=ExportFlag0,PlotFlag=PlotFlag0,cdConstr=cdConstr0,ow=ow0,count,stream,dummy,dummy2,dummy3,dummy4,YFile,FitArgList,FitConstrList,FitStartList,FitOut,(*FitOutList,*)it,Par,ici,idi,Residual,Chi2RedResidual,LogdIResidual,(*ResidualList,Chi2RedResidualList,LogdIResidualList,*)PlotArgList,pexpfit,pexpfitList,cdList,chsList,chlList,pBarChartList,pImg,ImgSizeUnit,Nsp,Nst(* Nst is Nmaxst-1, i.e. 4 for max. 5-stacks *),exp,set,Nset,fsp,fst(*,NY*),col,AddConstraintsY,FF,RetVecIF,chi,YFileListExistLocal},
(* check directories *)
If[StringTake[YFileDir,-1]!="/",YFileDir=YFileDir<>"/"];
If[DirectoryQ[YFileDir]==False,Print["YFile directory "<>YFileDir<>" does not exist. Exit."];Exit[];];
(* append slash if it does not exist yet *)
If[StringTake[OutDir,-1]!="/",OutDir=OutDir<>"/"];
(* Check if OutDir exists, otherwise create it *)
(* Don't use CreateDirectory[OutDir]; cause of permissions *)
(* One might check return of Run[""] command *)
If[DirectoryQ[OutDir]==False,Print["Out directory "<>OutDir<>" does not exist. Create directory."];Run["mkdir -m u=rwx,g=rx,o=rx "<>OutDir];];
(* Make Xnmode, expfileconc, YFileListLocal, Smear, Ymode, Tscf suitable lists if it comes only as a string or 1D-array *)
If[Length[Dimensions[YFileListLocal]]==0,YFileListLocal={{YFileListLocal}};];
If[Length[Dimensions[YFileListLocal]]==1,YFileListLocal=Transpose[{YFileListLocal}];];(* Transpose must be used ! *)
(* if overwrite flag is False (default), fit only those YFiles that do not yet exist in the directory (png exists?) *)
(* to overwrite all exist. files choose True for ow *)
If[ow==False,
YFileListExistLocal=FileNames[OutDir<>"*.png"];
YFileListExistLocal=StringTrim[StringTrim[#,OutDir],".png"]&/@YFileListExistLocal;
(* bring to same structure as YFileListLocal *)
YFileListExistLocal={#}&/@YFileListExistLocal;
(* now take the complement and overwrite YFileListLocal *)
If[Length[YFileListExistLocal]>0,YFileListLocal=Complement[YFileListLocal,YFileListExistLocal];];
If[Length[YFileListLocal]==0,Print["All fits for YFileListLocal already exist in directory. Exit."];Exit[];];
];
(* for AddConstraints a globally visible copy of YFileListLocal must be provided as well as for DumpSave *)
Clear[YFileListGlobal];YFileListGlobal=YFileListLocal;
(* Set up Nset *)
If[Depth[expfileconc]-1==1,expfileconc={expfileconc};];
Nset=Length[expfileconc];
(* Check other inputs *)
(* Xnmode *)
If[Length[Dimensions[Xnmode]]==0,Xnmode=Table[Xnmode,{i,1,Nset}];];
If[Length[Xnmode]!=Nset,Print["Length of Xnmode does not match Nset. Exit."];Exit[];];
(* plsc *)
If[Length[Dimensions[plsc]]==0,plsc=Table[plsc,{i,1,Nset}];];
If[Length[plsc]!=Nset,Print["Length of plsc does not match Nset. Exit."];Exit[];];
(* Ymode *)
(* Ymode allows to use different Yfiles for different datasets i.e. different simulations for different expdata *)
If[Length[Dimensions[Ymode]]==0,Ymode=Table[Ymode,{i,1,Nset}];];
If[Length[Ymode]!=Nset,Print["Max of Ymode does not match Nset."];Exit[];];
If[Max[Ymode]>Dimensions[YFileListLocal][[2]],Print["Max of Ymode does not match Dimensions of YFileListLocal. Exit."];Exit[];];
(* Smear *)
If[Length[Dimensions[Smear]]==1,Smear=Table[Smear,{i,1,Nset}];];
If[Length[Smear]!=Nset,Print["Length of Smear does not match Nset. Exit."];Exit[];];
(* Tscf *)
If[Length[Dimensions[Tscf]]==0,Tscf=Table[Tscf,{i,1,Nset}];];
If[Length[Tscf]!=Nset,Print["Length of Tscf does not match Nset. Exit."];Exit[];];
(* ycohscf *)
If[Depth[ycohscf]-1==1,ycohscf=Table[ycohscf,{i,1,Nset}];];
If[Length[ycohscf]!=Nset,Print["Length of ycohscf does not match Nset. Exit."];Exit[];];
(* FitTarF e.g. T, Chi2, Tv01, ... use Log as default scf *)
If[Depth[FitTarF]-1==0,FitTarF={FitTarF}];
If[Length[FitTarF]==1,AppendTo[FitTarF,Log];];
If[(ToString[FitTarF[[1]]]!="T")&&(ToString[FitTarF[[1]]]!="Chi2")&&(ToString[FitTarF[[1]]]!="Tv01"),Print["Unknown Fit Target Function FitTarF "<>ToString[FitTarF[[1]]]<>". Exit."];Exit[];];
(* set FF and RetVecIF (vectors or interpolation functions for Y's) *)
If[ToString[FitTarF[[1]]]=="T",FF=F;RetVecIF=False;];
If[ToString[FitTarF[[1]]]=="Chi2",FF=F;RetVecIF=False;];
If[ToString[FitTarF[[1]]]=="Tv01",FF=Fv01;RetVecIF=True;];
(* define colors *)
col={{Blue,Cyan},{Red,Orange},{Green,Darker[Green,0.5]},{Brown,Darker[Brown,0.65]},{Black,Gray},{Pink,Darker[Yellow,0.05]},{Magenta,Darker[Magenta,0.6]}};
If[Length[col]<Nset,Print["Nset is larger than available colors. Increase the number of colors in source code. Exit."];Exit[];];
(* Set up NY *)
(* NY=Max[Ymode]; *)

(* define global (shared) lists *)
FitOutList=Table[{},{i,1,Length[YFileListLocal]}];
ResidualList=Table[{},{i,1,Length[YFileListLocal]}];
Chi2RedResidualList=Table[{},{i,1,Length[YFileListLocal]}];
LogdIResidualList=Table[{},{i,1,Length[YFileListLocal]}];

(* YFileList=YFileListLocal *)
SetSharedVariable[FitOutList,ResidualList,Chi2RedResidualList,LogdIResidualList,YFileListGlobal];

ParallelDo[
YFile=YFileListLocal[[Y]];
(* open logfile *)
Print["Write log-file "<>OutDir<>YFile[[1]]<>".log"];
stream=OpenWrite[OutDir<>YFile[[1]]<>".log"];
If[stream==$Failed,Print["Cannot write log-file "<>OutDir<>YFile[[1]]<>".log Exit."];Exit[];];
(* redirect messages to logfile *)
$Messages=Append[$Messages,stream];
Off[General::stop];
(* load exp files *)
exp=loadexp[expfileconc[[All,1]],True,WriteString[stream,#<>"\n"]&];
WriteString[stream,"\n"];
(* setup set and fsp, fst *)
set=Table[{},{i,1,Nset}];
fsp=Table[{},{i,1,Nset}];
fst=Table[{},{i,1,Nset}];
(* load YFiles and create set from exp, assume same amount of Nsp and Nst can be found with the given NMaxsp and NMaxst !!! *)
Do[
set[[i]]=createset[exp[[i]],Fitsmin,Fitsmax,True,WriteString[stream,#<>"\n"]&];
WriteString[stream,"\n"];,{i,1,Nset}];
(* here: return 3D matrices fsp/fst[[l,p]][[s]] according to the experimental s-points within the Fitrange -> use set[[i]] instead of exp[[i]] *)
Do[{Nsp,Nst,fsp[[i]],fst[[i]]}=loadY[RetVecIF,YFileDir<>YFile[[Ymode[[i]]]],set[[i]],Xnmode[[i]],expfileconc[[i,2]],Smear[[i]],Nmaxsp,Nmaxst,True,WriteString[stream,#<>"\n"]&];
WriteString[stream,"\n"];
,{i,1,Nset}];

(* Print PartStart array *)
WriteString[stream,"ParStart = "<>ToString[ParStart]<>"\n"];
WriteString[stream,"\n"];

(* apply checks for number of parameters and presence of initial value if fixed *)
If[Length[ParStart]!=(Nsp+Nst+4*Nset),Print["There must be "<>ToString[Nsp+Nst+4*Nset]<>" fit parameters. Exit."];Exit[];];
Do[If[ParStart[[i,2]]==False&&Length[ParStart[[i]]]<3,Print["Parameter "<>ParStart[[i,1]]<>" is fixed, but no value is provided. Exit."];Exit[];];,{i,1,Length[ParStart]}];(* in the following we know that all fixed values are given *)

(* Argument list for fit function *)
(* when cdConstr[[1]]==True check that all c_i are fixed, Nsp>0 and normalize the sum of all c_i to 1.0 *)
If[cdConstr[[1]]==True&&Nsp==0,Print["Nsp must be >0 if cdConstr[[1]]==True. Exit."];Exit[];];(* in the following we know that Nsp>0 *)
If[cdConstr[[1]]==True&&Norm[ParStart[[1;;Nsp,2]]/.{True->0,False->1},1]!=Nsp,Print["All c_i must be fixed when cdConstr[[1]]==True. Exit."];Exit[];];(* in the following we know that for all Nsp c_i fixed values are given *)
If[cdConstr[[1]]==True,ParStart[[1;;Nsp,3]]/=Total[ParStart[[1;;Nsp,3]]];];(* in the following we know that sum(c_i)=1 *)
If[cdConstr[[1]]==True,If[cdConstr[[2,2]]==False&&Length[cdConstr[[2]]]<3,Print["Parameter "<>cdConstr[[2,1]]<>" is fixed, but no value is provided. Exit."];Exit[];];];

(* get number from upper boundary of LicoConstr *)
LicoConstr2Num=StringReplace[LicoConstr[[2]],{"="->"","<"->"",">"->""}];
(* c's and d's *)
count=0;
(* when cdConstr[[1]]==True, c_i->c_i*chi, d_i->d_i*(#2-chi) *)
dummy=dummy2="";
If[cdConstr[[1]]==True,dummy3=If[cdConstr[[2,2]]==True,1,3];dummy=cdConstr[[2,dummy3]]<>"*";dummy2="("<>LicoConstr2Num<>"-"<>cdConstr[[2,dummy3]]<>")*";];

(* start to assemble FitArgList *)
FitArgList="{"<>StringJoin[Table[dummy<>If[ParStart[[i,2]],ParStart[[i,1]],ToString[ParStart[[i,3]]]]<>",",{i,1,Nsp}]]<>StringJoin[Table[dummy2<>If[ParStart[[Nsp+i,2]],ParStart[[Nsp+i,1]],ToString[ParStart[[Nsp+i,3]]]]<>",",{i,1,Nst}]];
count+=Nsp+Nst;

(* contrasts and background *)
Do[Do[FitArgList=FitArgList<>If[ParStart[[count+j,2]],ParStart[[count+j,1]],ToString[ParStart[[count+j,3]]]]<>",",{j,1,4}];count+=4;,{i,1,Nset}];
(* chiXn{i} variables for the i-th set *)
Do[FitArgList=FitArgList<>If[ycohscf[[i,1]]==True,"chiXn"<>ToString[i],ToString[ycohscf[[i,2]]]]<>",";,{i,1,Nset}];

(* terminate string and transform to an expression *)
FitArgList=StringDrop[FitArgList,-1]<>"}";
FitArgList=ToExpression[FitArgList];

(* basic constraints for linear coefficients c_i and d_i *)
count=0;
(* >0 for those c_i and d_i that will be optimized *)
FitConstrList="{"<>StringJoin[Table[If[ParStart[[i,2]],ParStart[[i,1]]<>">0.0,",""],{i,1,Nsp}]]<>StringJoin[Table[If[ParStart[[Nsp+i,2]],ParStart[[Nsp+i,1]]<>">0.0,",""],{i,1,Nst}]];
(* sum( c's and d's that are optimized ) == 1, will be only applied if at least two coefficient will be optimized, one makes not much sense, fixing this parameter is more senseful ! *)
dummy=dummy2=dummy3="";
If[cdConstr[[1]]==True,dummy4=If[cdConstr[[2,2]]==True,1,3];dummy=cdConstr[[2,dummy4]]<>"*(";dummy2="("<>LicoConstr2Num<>"-"<>cdConstr[[2,dummy4]]<>")*(";dummy3="0)+";];
If[Length[Cases[ParStart[[1;;Nsp+Nst,2]],True]]>1,FitConstrList=FitConstrList<>LicoConstr[[1]]<>dummy<>StringJoin[Table[If[ParStart[[i,2]],ParStart[[i,1]],ToString[ParStart[[i,3]]]]<>"+",{i,1,Nsp}]]<>dummy3<>dummy2<>StringJoin[Table[If[ParStart[[Nsp+i,2]],ParStart[[Nsp+i,1]],ToString[ParStart[[Nsp+i,3]]]]<>"+",{i,1,Nst}]]<>dummy3;
FitConstrList=StringDrop[FitConstrList,-1]<>LicoConstr[[2]]<>",";
];
count+=Nsp+Nst;

(* additional userdefined constraints especially for rho's and sld's, ignore multiplicities of parameters for different datasets !!! *)
(* set >0 for those Xa_i's and na_i's that will be optimized if no other constraints are given for them e.g. {Xa1,True} -> Xa1>0, {Xa1,True,0.0,"#>0.1"} -> Xa1>0.1 *)
Do[Do[If[Count[ParStart[[Nsp+Nst+1;;count+j,1]],ParStart[[count+j,1]]]==1,dummy=If[ParStart[[count+j,2]]&&Length[ParStart[[count+j]]]==4,StringReplace[ParStart[[count+j,4]],"#"->ParStart[[count+j,1]]]<>",",""];If[(j==4)&&ParStart[[count+j,2]]&&(Length[ParStart[[count+j]]]<4),dummy=ParStart[[count+j,1]]<>">0.0,";(* else do nothing *)];If[dummy!="",WriteString[stream,ToString[dummy]<>"\n"];];FitConstrList=FitConstrList<>dummy;];
,{j,1,4}];
(* starting with count=Nsp+Nst+(i-1)*Nset *)
count+=4;
,{i,1,Nset}];
WriteString[stream,"\n"];

(* chiXn{i} constraints if provided *)
Do[If[ycohscf[[i,1]]&&Length[ycohscf[[i]]]==3,FitConstrList=FitConstrList<>StringReplace[ycohscf[[i,3]],"#"->"chiXn"<>ToString[i]]<>",";];,{i,1,Nset}];
(* chi constraint if cdConstr[[1]]==True *)
If[cdConstr[[1]]==True,FitConstrList=FitConstrList<>If[Length[cdConstr[[2]]]>3,StringReplace[cdConstr[[2,4]],"#"->cdConstr[[2,1]]],"0.0<"<>cdConstr[[2,1]]<>StringReplace[LicoConstr[[2]],"=="->"<"]]<>",";];

(* constraints from AddConstraints, use YFileListGlobal in AddConstraints to access stabilizer layer thicknesses *)
AddConstraintsY=ToString[#,InputForm]&/@Evaluate/@ToExpression/@AddConstraints;
FitConstrList=FitConstrList<>StringJoin[#<>","&/@AddConstraintsY];

(* finish FitConstrList *)
FitConstrList=StringDrop[FitConstrList,-1]<>"}";
FitConstrList=ToExpression[FitConstrList];

(* parameters names (and initial values for FindMinimum) for fit functions, ignore multiplicities of parameters for different datasets !!!, list only those that shall be optimized (True) *)
(* for NMinimize no initial values are possible, if provided they will be ignored *)
If[ToString[FitFunc]!="NMinimize"&&ToString[FitFunc]!="FindMinimum",Print["Unknown Fit Function "<>ToString[FitFunc]<>". Exit."];Exit[];];
count=Nsp+Nst;
FitStartList=If[ToString[FitFunc]=="NMinimize",ParStart[[Flatten[Position[ParStart[[1;;Nsp+Nst,2]],True]],1]],ParStart[[Flatten[Position[ParStart[[1;;Nsp+Nst,2]],True]],{1,3}]]];
(* append j-th variable in i-th set (index k:=Nsp+Nst+(i-1)*4+j) only if not already included in a previous index in the range Nsp+Nst+1:k-1, furthermore the (class of this)variable should have flag true *)
Do[Do[If[Count[ParStart[[Nsp+Nst+1;;count+j,1]],ParStart[[count+j,1]]]==1&&ParStart[[count+j,2]],AppendTo[FitStartList,If[ToString[FitFunc]=="NMinimize",ParStart[[count+j,1]],ParStart[[count+j,{1,3}]]]];];
,{j,1,4}];
(* count=Nsp+Nst+(i-1)*4 *)
count+=4;
,{i,1,Nset}];

(* chiXn{i} *)
Do[If[ycohscf[[i,1]]==True,AppendTo[FitStartList,If[ToString[FitFunc]=="NMinimize","chiXn"<>ToString[i],{"chiXn"<>ToString[i],ycohscf[[i,2]]}]]];,{i,1,Nset}];
(* chi use by default initial value 0.0 (only stacks) *)
If[cdConstr[[1]]==True,AppendTo[FitStartList,If[ToString[FitFunc]=="NMinimize",cdConstr[[2,1]],{cdConstr[[2,1]],cdConstr[[2,3]]}]]];
FitStartList=ToExpression[FitStartList];
(* write to logfile *)
WriteString[stream,ToString[FitFunc]<>"["<>ToString[FitTarF[[1]]]<>"["<>ToString[FitArgList]<>","<>ToString[Nsp]<>","<>ToString[Nst]<>","<>"<set>"<>","<>"<fsp>"<>","<>"<fst>"<>","<>ToString[Tscf]<>","<>ToString[FitTarF[[2]]]<>"]"<>","<>ToString[FitConstrList,InputForm]<>"},"<>ToString[FitStartList]<>", MaxIterations->"<>ToString[FitMaxIt]<>", Method->"<>ToString[FitMethod]<>", StepMonitor:>it++]"<>"\n"];
WriteString[stream,"\n"];

(* start fitting procedure *)
it=0;
If[
PlotFlag==False,
(* fit *)
WriteString[stream,"FitArgList = "<>ToString[FitArgList]<>"\n"];
WriteString[stream,"dim = "<>ToString[Dimensions[set]]<>" "<>ToString[Dimensions[fsp]]<>" "<>ToString[Dimensions[fst]]<>" "<>ToString[Dimensions[Tscf]]<>"\n"];
WriteString[stream,"depth = "<>ToString[Depth[set]]<>" "<>ToString[Depth[fsp]]<>" "<>ToString[Depth[fst]]<>" "<>ToString[Depth[Tscf]]<>"\n"];
WriteString[stream,"\n"];
FitOut=FitFunc@@{{FitTarF[[1]]@@{FitArgList,Nsp,Nst,set,fsp,fst,Tscf,FitTarF[[2]]},FitConstrList},FitStartList,MaxIterations->FitMaxIt,Method->FitMethod,StepMonitor:> it++};,
(* plot only, it=0, Residual=0, fitted parameters==initial values -> all initial values must be provided, also chiXn(via ycohscf) and chi(via cdConstr), plscf and LicoConstr(via c_i) can be considered *)
WriteString[stream,"Creating plots only, fitting is deactivated\n"];

(* when cdConstr[[1]]==True, c_i->c_i*chi, d_i->d_i*(#2-chi) *)
dummy=dummy2="";
If[cdConstr[[1]]==True,dummy3=If[cdConstr[[2,2]]==True,1,3];dummy=cdConstr[[2,dummy3]]<>"*";dummy2="("<>LicoConstr2Num<>"-"<>cdConstr[[2,dummy3]]<>")*";];
dummy4="{";
dummy4=dummy4<>StringJoin[Table[dummy<>If[ParStart[[i,2]],ParStart[[i,1]],ToString[ParStart[[i,3]]]]<>",",{i,1,Nsp}]];
dummy4=dummy4<>StringJoin[Table[dummy2<>If[ParStart[[i,2]],ParStart[[i,1]],ToString[ParStart[[i,3]]]]<>",",{i,Nsp+1,Nsp+Nst}]];
dummy4=dummy4<>StringJoin[Table[If[ParStart[[i,2]],ParStart[[i,1]],ToString[ParStart[[i,3]]]]<>",",{i,Nsp+Nst+1,Length[ParStart]}]];
Do[If[ycohscf[[i,1]]==True,dummy4=dummy4<>"chiXn"<>ToString[i]<>"->"<>ToString[ycohscf[[i,2]]]<>","];,{i,1,Nset}];
dummy4=StringDrop[dummy4,-1]<>"}";
FitOut={0,ToExpression[dummy4]};
];

(* don't use AppendTo[FitOutList,FitOut]; -> order will not match order in YFileListGlobal *)
FitOutList[[Y]]=FitOut;
Par=FitOut[[2]];

(* write fit parameters *)
WriteString[stream,"Fitted parameters:\n"];
Do[WriteString[stream,StringReplace[#,{"->"->"=","*^"->"*10^"}]&@ToString[#,InputForm]&@Par[[i]]<>"\n"];,{i,1,Length[Par]}];
WriteString[stream,"\n"];

(* write fixed parameters (if fit-flag was set to False) *)
WriteString[stream,"Fixed parameters:\n"];
Do[If[ParStart[[i,2]]==False,WriteString[stream,ParStart[[i,1]]<>" = "<>ToString[ParStart[[i,3]],InputForm]<>"\n"]];,{i,1,Length[ParStart]}];
WriteString[stream,"\n"];

(* write ici and idi and other params derived from fit params *)
WriteString[stream,"Derived parameters:\n"];

If[Nsp>0,
ici=0.0;
Do[ici+=i*If[ParStart[[i,2]]==False,ParStart[[i,3]],ToExpression[ParStart[[i,1]]]/.Par];,{i,1,Nsp}];
dummy=0.0;
Do[dummy+=If[ParStart[[i,2]]==False,ParStart[[i,3]],ToExpression[ParStart[[i,1]]]/.Par];,{i,1,Nsp}];
ici/=dummy;
WriteString[stream,"ici = "<>ToString[ici]<>"\n"];
];

If[Nst>0,
idi=0.0;
Do[idi+=i*If[ParStart[[i,2]]==False,ParStart[[i,3]],ToExpression[ParStart[[i,1]]]/.Par];,{i,Nsp+1,Nsp+Nst}];
dummy=0.0;
Do[dummy+=If[ParStart[[i,2]]==False,ParStart[[i,3]],ToExpression[ParStart[[i,1]]]/.Par];,{i,Nsp+1,Nsp+Nst}];
idi/=dummy;
WriteString[stream,"idi = "<>ToString[idi]<>"\n"];
];

WriteString[stream,"\n"];


(* create plot of experimental and fit data, compute Residuals *)
(* when cdConstr[[1]]==True, c_i->c_i*chi, d_i->d_i*(#2-chi) *)
(* If PartStart[[i,2]] is True, use param name PartStart[[i,1]] and replace it by fitted param, otherwise use fixed value PartStart[[i,3]] *)
dummy=dummy2="";
If[cdConstr[[1]]==True,dummy3=If[cdConstr[[2,2]]==True,1,3];dummy=cdConstr[[2,dummy3]]<>"*";dummy2="("<>LicoConstr2Num<>"-"<>cdConstr[[2,dummy3]]<>")*";];
PlotArgList="{";
PlotArgList=PlotArgList<>StringJoin[Table[dummy<>If[ParStart[[i,2]],ParStart[[i,1]],ToString[ParStart[[i,3]]]]<>",",{i,1,Nsp}]];
PlotArgList=PlotArgList<>StringJoin[Table[dummy2<>If[ParStart[[i,2]],ParStart[[i,1]],ToString[ParStart[[i,3]]]]<>",",{i,Nsp+1,Nsp+Nst}]];
PlotArgList=PlotArgList<>StringJoin[Table[If[ParStart[[i,2]],ParStart[[i,1]],ToString[ParStart[[i,3]]]]<>",",{i,Nsp+Nst+1,Length[ParStart]}]];

(* include also chiXn{i} *)
Do[PlotArgList=PlotArgList<>If[ycohscf[[i,1]]==True,"chiXn"<>ToString[i],ToString[ycohscf[[i,2]]]]<>",";,{i,1,Nset}];
PlotArgList=StringDrop[PlotArgList,-1]<>"}";
PlotArgList=ToExpression[PlotArgList]/.Par;
If[cdConstr[[1]]==True,chi=If[cdConstr[[2,2]]==True,ToExpression[cdConstr[[2,1]]]/.Par,cdConstr[[2,3]]];];

(* Residual value over the whole fit-range for all sets and for each set *)
Residual={FitOut[[1]]};
Do[dummy=Join[PlotArgList[[1;;Nsp+Nst]],PlotArgList[[Nsp+Nst+1+(i-1)*4;;Nsp+Nst+i*4]],{PlotArgList[[Nsp+Nst+4*Nset+i]]}];
dummy2="{"<>StringJoin[Num2Str[#,5,4,""]<>","&/@dummy];
dummy2=StringDrop[dummy2,-1]<>"}";
WriteString[stream,"FitArgList = "<>dummy2<>"\n"];
WriteString[stream,"dim = "<>ToString[Dimensions[set[[i]]]]<>" "<>ToString[Dimensions[fsp[[i]]]]<>" "<>ToString[Dimensions[fst[[i]]]]<>" "<>ToString[Dimensions[Tscf[[i]]]]<>"\n"];
WriteString[stream,"depth = "<>ToString[Depth[set[[i]]]]<>" "<>ToString[Depth[fsp[[i]]]]<>" "<>ToString[Depth[fst[[i]]]]<>" "<>ToString[Depth[Tscf[[i]]]]<>"\n"];
WriteString[stream,"\n"];
AppendTo[Residual,FitTarF[[1]]@@{dummy,Nsp,Nst,set[[i]],fsp[[i]],fst[[i]],Tscf[[i]],FitTarF[[2]]}];
,{i,1,Nset}];

(* Residual value over the Braggpeak-range for all sets and for each set *)
AppendTo[Residual,FitTarF[[1]]@@{PlotArgList,Nsp,Nst,set,fsp,fst,Tscf,FitTarF[[2]],0.15,0.35}];
Do[dummy=Join[PlotArgList[[1;;Nsp+Nst]],PlotArgList[[Nsp+Nst+1+(i-1)*4;;Nsp+Nst+i*4]],{PlotArgList[[Nsp+Nst+4*Nset+i]]}];
AppendTo[Residual,FitTarF[[1]]@@{dummy,Nsp,Nst,set[[i]],fsp[[i]],fst[[i]],Tscf[[i]],FitTarF[[2]],0.15,0.35}];
,{i,1,Nset}];

(* Residual value over the whole fit-range (sets have been cutted to full range) using {Chi2,red} for all sets and for each set *)
Chi2RedResidual={Chi2@@{PlotArgList,Nsp,Nst,set,fsp,fst,Tscf,"red"}};
Do[dummy=Join[PlotArgList[[1;;Nsp+Nst]],PlotArgList[[Nsp+Nst+1+(i-1)*4;;Nsp+Nst+i*4]],{PlotArgList[[Nsp+Nst+4*Nset+i]]}];
AppendTo[Chi2RedResidual,Chi2@@{dummy,Nsp,Nst,set[[i]],fsp[[i]],fst[[i]],Tscf[[i]],"red"}];
,{i,1,Nset}];

(* Residual value over the whole fit-range (sets have been cutted to full range) using {T,Log} for all sets and for each set *)
LogdIResidual={T@@{PlotArgList,Nsp,Nst,set,fsp,fst,Tscf,Log}};
Do[dummy=Join[PlotArgList[[1;;Nsp+Nst]],PlotArgList[[Nsp+Nst+1+(i-1)*4;;Nsp+Nst+i*4]],{PlotArgList[[Nsp+Nst+4*Nset+i]]}];
AppendTo[LogdIResidual,T@@{dummy,Nsp,Nst,set[[i]],fsp[[i]],fst[[i]],Tscf[[i]],Log}];
,{i,1,Nset}];

(* don't use AppendTo[ResidualList, Residual]; etc -> order will not match order in YFileListGlobal *)
ResidualList[[Y]]=Residual;
Chi2RedResidualList[[Y]]=Chi2RedResidual;
LogdIResidualList[[Y]]=LogdIResidual;
WriteString[stream,"Number of iterations = "<>ToString[it]<>"\n"];
WriteString[stream,"Target function values = "<>StringJoin[Riffle[ToString/@N[Residual[[1;;1+Nset]],4],", "]]<>"\n"];
WriteString[stream,"Chi2Red function values = "<>StringJoin[Riffle[ToString/@N[Chi2RedResidual[[1;;1+Nset]],4],", "]]<>"\n"];
WriteString[stream,"LogdI function values = "<>StringJoin[Riffle[ToString/@N[LogdIResidual[[1;;1+Nset]],4],", "]]<>"\n"];
WriteString[stream,"Target function value (Braggpeak range) = "<>StringJoin[Riffle[ToString/@N[Residual[[2+Nset;;]],4],", "]]<>"\n"];
WriteString[stream,"\n"];

(* plot *)
pexpfitList={};pBarChartList={};ImgSizeUnit=320;
Do[
dummy=Join[PlotArgList[[1;;Nsp+Nst]],PlotArgList[[Nsp+Nst+1+(i-1)*4;;Nsp+Nst+i*4]],{PlotArgList[[Nsp+Nst+4*Nset+i]]}];
AppendTo[pexpfitList,ErrorListLogLogPlot[{{#[[1]],plsc[[i]]*#[[2]]},ErrorBar[0*#[[3]],plsc[[i]]*#[[4]]]}&/@exp[[i]],Joined->False,PlotStyle->{col[[i,1]],Thick},PlotRange->PlRange]];
(* note the printed numbers might look strange if exponentials like 10^-8 are printed *)
WriteString[stream,"ListLogLogPlot[Transpose[{#,"<>ToString[plsc[[i]]]<>"*"<>ToString[FF]<>"["<>StringJoin[Num2Str[#,5,4,""]<>","&/@dummy]<>"fsp[["<>ToString[i]<>"]],fst[["<>ToString[i]<>"]],"<>ToString[Nsp]<>","<>ToString[Nst]<>",#]}&@set[["<>ToString[i]<>"]][[All,1]]],Joined->True,PlotStyle->{"<>ToString[col[[i,2]]]<>",Thick},PlotRange->PlRange,PlotMarkers->{Automatic,Small}]"<>"\n"];
WriteString[stream,"\n"];
dummy2=Transpose[{#,plsc[[i]]*FF@@{dummy,fsp[[i]],fst[[i]],Nsp,Nst,#}}&@set[[i]][[All,1]]];
If[ExportFlag==True,Export[OutDir<>YFile[[1]]<>"_set_"<>ToString[i]<>"_fit.dat",dummy2,"Table"]];
AppendTo[pexpfitList,ListLogLogPlot[dummy2,Joined->True,PlotStyle->{col[[i,2]],Thick},PlotRange->PlRange,PlotMarkers->{Automatic,Small}]];
,{i,1,Nset}];
pexpfit=Show[pexpfitList,Frame->True,PlotLabel->Style[Framed[ToString[OutDir]<>ToString[YFile[[1]]]<>"\n"<>"it = "<>ToString[it]<>"    "<>"T = "<>StringJoin[Riffle[ToString/@Residual[[1;;1+Nset]],", "]]<>"    "<>"T (Bragg) = "<>StringJoin[Riffle[ToString/@Residual[[2+Nset;;]],", "]]<>If[cdConstr[[1]]==True,"    "<>cdConstr[[2,1]]<>" = "<>Num2Str[chi,5,4,""],""]],16,Background->LightYellow],ImageSize->3*ImgSizeUnit,DisplayFunction->Identity];

(* create barchart of coefficients c_i and d_i *)
cdList=Labeled[#,ToString[NumberForm[N[Round[#*10^4]/10^4],{5,4}]],Above]&/@PlotArgList[[1;;Nsp+Nst]];
chlList=ParStart[[1;;Nsp+Nst,1]];
chsList=Join[Table[Blue,{i,1,Nsp}],Table[Green,{i,1,Nst}]];
AppendTo[pBarChartList,BarChart[cdList,ChartLabels->chlList,ChartStyle->chsList,Frame->True,FrameTicks->{None, Automatic},ImageSize->ImgSizeUnit]];

(* create barchart for rho and sld *)
Do[
cdList=Labeled[#,ToString[NumberForm[N[Round[#*10^5]/10^5],{4,3}]],Above]&/@PlotArgList[[Nsp+Nst+1+(i-1)*4;;Nsp+Nst+3+(i-1)*4]];
chlList=ParStart[[Nsp+Nst+1+(i-1)*4;;Nsp+Nst+3+(i-1)*4,1]];
chsList=Table[col[[i,2]],{j,1,3}];
AppendTo[pBarChartList,BarChart[cdList,ChartLabels->Placed[chlList,Top],ChartStyle->chsList,Frame->True,FrameTicks->{None, Automatic},PlotRange->{{0.5,3.5},If[Xnmode[[i]]=="X",{250,530},{-0.6,8}]}, AspectRatio->1,ImageSize->3*ImgSizeUnit/Nset]];
,{i,1,Nset}];

(* create final image and export *)
pImg=Grid[{{pexpfit},{GraphicsGrid[{pBarChartList[[2;;]]}]},{pBarChartList[[1]]}},Frame->All,Spacings->0];Export[OutDir<>YFile[[1]]<>".png",pImg,ImageSize->3*ImgSizeUnit];

(* close logfile *)
$Messages=$Messages[[{1}]];
On[General::stop];
Close[stream];

,{Y,1,Length[YFileListLocal]}];(* end (Parallel)Do *)

(* finally the MasterKernel ($KernelID 0) saves the global visably variables in the mx file again, in parallel DumSave does not work, even not for a specific $KernelID only *)
DumpSave[OutDir<>"T.mx",{YFileListGlobal,ResidualList,FitOutList}];
DumpSave[OutDir<>"Chi2Red.mx",{YFileListGlobal,Chi2RedResidualList,FitOutList}];
DumpSave[OutDir<>"LogdI.mx",{YFileListGlobal,LogdIResidualList,FitOutList}];

];














(*
TODOs:
-instead of files also accept s-ranges with conc and X/n flag, do not calc Residuals then and don't plot

*)

Clear[BatchMultiPlot];
BatchMultiPlot[OutDir0_,Xnmode0_,expfileconc0_,YFileDir0_,YFileListLocal0_,Nmaxsp0_,Nmaxst0_,Fitsmin0_,Fitsmax0_,ParStart0_,ycohscf0_,PlRange0_,plsc0_:1.0,Ymode0_:1,Smear0_:{0,0.0},Tscf0_:1.0,PlotFlag0_:True,ow0_:False]:=Module[{OutDir=OutDir0,Xnmode=Xnmode0,expfileconc=expfileconc0,YFileDir=YFileDir0,YFileListLocal=YFileListLocal0,Nmaxsp=Nmaxsp0,Nmaxst=Nmaxst0,Fitsmin=Fitsmin0,Fitsmax=Fitsmax0,ParStart=ParStart0,ycohscf=ycohscf0,PlRange=PlRange0,plsc=plsc0,Ymode=Ymode0,Smear=Smear0,Tscf=Tscf0,
PlotFlag=PlotFlag0,ImgSizeUnit,pImg,cdList,chlList,chsList,pexpfit,pexpfitList,pBarChartList,
exp,set,Nset,
Nsp,Nst,fsp,fst,YFile,
RetVecIF,FF,
PlotArgList,
Chi2RedResidual,LogdIResidual,
ow=ow0,stream,
col,YFileListExistLocal,
dummy,dummy2,dummy3,dummy4
},

(* check directories *)
If[StringTake[YFileDir,-1]!="/",YFileDir=YFileDir<>"/"];
If[DirectoryQ[YFileDir]==False,Print["YFile directory "<>YFileDir<>" does not exist. Exit."];Exit[];];
(* append slash if it does not exist yet *)
If[StringTake[OutDir,-1]!="/",OutDir=OutDir<>"/"];

(* Check if OutDir exists, otherwise create it *)
(* Don't use CreateDirectory[OutDir]; cause of permissions *)
(* One might check return of Run[""] command *)
If[DirectoryQ[OutDir]==False,Print["Out directory "<>OutDir<>" does not exist. Create directory."];Run["mkdir -m u=rwx,g=rx,o=rx "<>OutDir];];

(* Make Xnmode, expfileconc, YFileListLocal, Smear, Ymode suitable lists if it comes only as a string or 1D-array *)
If[Length[Dimensions[YFileListLocal]]==0,YFileListLocal={{YFileListLocal}};];
If[Length[Dimensions[YFileListLocal]]==1,YFileListLocal=Transpose[{YFileListLocal}];];(* Transpose must be used ! *)

(* if overwrite flag is False (default), fit only those YFiles that do not yet exist in the directory (png exists?) *)
(* to overwrite all exist. files choose True for ow *)
If[ow==False,
YFileListExistLocal=FileNames[OutDir<>"*.png"];
YFileListExistLocal=StringTrim[StringTrim[#,OutDir],".png"]&/@YFileListExistLocal;
(* bring to same structure as YFileListLocal *)
YFileListExistLocal={#}&/@YFileListExistLocal;
(* now take the complement and overwrite YFileListLocal *)
If[Length[YFileListExistLocal]>0,YFileListLocal=Complement[YFileListLocal,YFileListExistLocal];];
If[Length[YFileListLocal]==0,Print["All fits for YFileListLocal already exist in directory. Exit."];Exit[];];
];

(* Set up Nset *)
If[Depth[expfileconc]-1==1,expfileconc={expfileconc};];
Nset=Length[expfileconc];

(* Check other inputs *)
(* Xnmode *)
If[Length[Dimensions[Xnmode]]==0,Xnmode=Table[Xnmode,{i,1,Nset}];];
If[Length[Xnmode]!=Nset,Print["Length of Xnmode does not match Nset. Exit."];Exit[];];
(* plsc *)
If[Length[Dimensions[plsc]]==0,plsc=Table[plsc,{i,1,Nset}];];
If[Length[plsc]!=Nset,Print["Length of plsc does not match Nset. Exit."];Exit[];];
(* Ymode *)
(* Ymode allows to use different Yfiles for different datasets i.e. different simulations for different expdata *)
If[Length[Dimensions[Ymode]]==0,Ymode=Table[Ymode,{i,1,Nset}];];
If[Length[Ymode]!=Nset,Print["Max of Ymode does not match Nset."];Exit[];];
If[Max[Ymode]>Dimensions[YFileListLocal][[2]],Print["Max of Ymode does not match Dimensions of YFileListLocal. Exit."];Exit[];];
(* Smear *)
If[Length[Dimensions[Smear]]==1,Smear=Table[Smear,{i,1,Nset}];];
If[Length[Smear]!=Nset,Print["Length of Smear does not match Nset. Exit."];Exit[];];
(* Tscf *)
If[Length[Dimensions[Tscf]]==0,Tscf=Table[Tscf,{i,1,Nset}];];
If[Length[Tscf]!=Nset,Print["Length of Tscf does not match Nset. Exit."];Exit[];];
(* ycohscf *)
If[Dimensions[ycohscf]==0,ycohscf=Table[ycohscf,{i,1,Nset}];];
If[Length[ycohscf]!=Nset,Print["Length of ycohscf does not match Nset. Exit."];Exit[];];

(* set FF and RetVecIF (vectors or interpolation functions for Y's) *)
FF=F;RetVecIF=False;


(* define colors *)
col={{Blue,Cyan},{Red,Orange},{Green,Darker[Green,0.5]},{Brown,Darker[Brown,0.65]},{Black,Gray},{Pink,Darker[Yellow,0.05]},{Magenta,Darker[Magenta,0.6]}};
If[Length[col]<Nset,Print["Nset is larger than available colors. Increase the number of colors in source code. Exit."];Exit[];];


ParallelDo[

YFile=YFileListLocal[[Y]];

(* open logfile *)
Print["Write log-file "<>OutDir<>YFile[[1]]<>".log"];
stream=OpenWrite[OutDir<>YFile[[1]]<>".log"];
If[stream==$Failed,Print["Cannot write log-file "<>OutDir<>YFile[[1]]<>".log Exit."];Exit[];];
(* redirect messages to logfile *)
$Messages=Append[$Messages,stream];
Off[General::stop];

(* load exp files *)
exp=loadexp[expfileconc[[All,1]],True,WriteString[stream,#<>"\n"]&];
WriteString[stream,"\n"];

(* setup set and fsp, fst *)
set=Table[{},{i,1,Nset}];
fsp=Table[{},{i,1,Nset}];
fst=Table[{},{i,1,Nset}];

(* load YFiles and create set from exp, assume same amount of Nsp and Nst can be found with the given NMaxsp and NMaxst !!! *)
Do[
set[[i]]=createset[exp[[i]],Fitsmin,Fitsmax,True,WriteString[stream,#<>"\n"]&];
WriteString[stream,"\n"];,{i,1,Nset}];
(* here: return 3D matrices fsp/fst[[l,p]][[s]] according to the experimental s-points within the Fitrange -> use set[[i]] instead of exp[[i]] *)
Do[{Nsp,Nst,fsp[[i]],fst[[i]]}=loadY[RetVecIF,YFileDir<>YFile[[Ymode[[i]]]],set[[i]],Xnmode[[i]],expfileconc[[i,2]],Smear[[i]],Nmaxsp,Nmaxst,True,WriteString[stream,#<>"\n"]&];
WriteString[stream,"\n"];
,{i,1,Nset}];

(* Print PartStart array *)
WriteString[stream,"ParStart = "<>ToString[ParStart]<>"\n"];
WriteString[stream,"\n"];

(* apply check for number of parameters and presence of initial value if fixed *)
If[Length[ParStart]!=(Nsp+Nst+4*Nset),Print["There must be "<>ToString[Nsp+Nst+4*Nset]<>" fit parameters. Exit."];Exit[];];



(* assemble PlotArgList *)
(* c_i, d_i, all rho for all sets, include also chiXn{i} *)
PlotArgList=Join[ParStart[[All,2]],ycohscf];

(* Residual value over the whole fit-range (sets have been cutted to full range) using {Chi2,red} for all sets and for each set *)
Chi2RedResidual={Chi2@@{PlotArgList,Nsp,Nst,set,fsp,fst,Tscf,"red"}};
Do[dummy=Join[PlotArgList[[1;;Nsp+Nst]],PlotArgList[[Nsp+Nst+1+(i-1)*4;;Nsp+Nst+i*4]],{PlotArgList[[Nsp+Nst+4*Nset+i]]}];
AppendTo[Chi2RedResidual,Chi2@@{dummy,Nsp,Nst,set[[i]],fsp[[i]],fst[[i]],Tscf[[i]],"red"}];
,{i,1,Nset}];

(* Residual value over the whole fit-range (sets have been cutted to full range) using {T,Log} for all sets and for each set *)
LogdIResidual={T@@{PlotArgList,Nsp,Nst,set,fsp,fst,Tscf,Log}};
Do[dummy=Join[PlotArgList[[1;;Nsp+Nst]],PlotArgList[[Nsp+Nst+1+(i-1)*4;;Nsp+Nst+i*4]],{PlotArgList[[Nsp+Nst+4*Nset+i]]}];
AppendTo[LogdIResidual,T@@{dummy,Nsp,Nst,set[[i]],fsp[[i]],fst[[i]],Tscf[[i]],Log}];
,{i,1,Nset}];

WriteString[stream,"Chi2Red function values = "<>StringJoin[Riffle[ToString/@N[Chi2RedResidual[[1;;1+Nset]],4],", "]]<>"\n"];
WriteString[stream,"LogdI function values = "<>StringJoin[Riffle[ToString/@N[LogdIResidual[[1;;1+Nset]],4],", "]]<>"\n"];
WriteString[stream,"\n"];


(* plot exp data *)
pexpfitList={};
pBarChartList={};
ImgSizeUnit=320;

Do[
dummy=Join[PlotArgList[[1;;Nsp+Nst]],PlotArgList[[Nsp+Nst+1+(i-1)*4;;Nsp+Nst+i*4]],{PlotArgList[[Nsp+Nst+4*Nset+i]]}];
AppendTo[pexpfitList,ErrorListLogLogPlot[{{#[[1]],plsc[[i]]*#[[2]]},ErrorBar[0*#[[3]],plsc[[i]]*#[[4]]]}&/@exp[[i]],Joined->False,PlotStyle->{col[[i,1]],Thick},PlotRange->PlRange]];
(* note the printed numbers might look strange if exponentials like 10^-8 are printed *)
WriteString[stream,"ListLogLogPlot[Transpose[{#,"<>ToString[plsc[[i]]]<>"*"<>ToString[FF]<>"["<>StringJoin[Num2Str[#,5,4,""]<>","&/@dummy]<>"fsp[["<>ToString[i]<>"]],fst[["<>ToString[i]<>"]],"<>ToString[Nsp]<>","<>ToString[Nst]<>",#]}&@set[["<>ToString[i]<>"]][[All,1]]],Joined->True,PlotStyle->{"<>ToString[col[[i,2]]]<>",Thick},PlotRange->PlRange,PlotMarkers->{Automatic,Small}]"<>"\n"];
WriteString[stream,"\n"];


(* export composed fit for each dataset *)
(* overall fit *)
dummy2=Transpose[{#,plsc[[i]]*FF@@{dummy,fsp[[i]],fst[[i]],Nsp,Nst,#}}&@set[[i]][[All,1]]];
Export[OutDir<>YFile[[1]]<>"_set_"<>ToString[i]<>"_fit.dat",dummy2,"Table"];

(* export individual sp and st contributions for each fit, putting all except the specific c_i or d_i to 0.0 and setting background to 0.0, include ycohscf *)
Do[
dummy3=dummy;
dummy3[[1;;Nsp+Nst]]=Table[0.0,{k,1,Nsp+Nst}];
dummy3[[j]]=dummy[[j]];
dummy3[[Nsp+Nst+4]]=0.0;
dummy4=Transpose[{#,plsc[[i]]*FF@@{dummy3,fsp[[i]],fst[[i]],Nsp,Nst,#}}&@set[[i]][[All,1]]];
Export[OutDir<>YFile[[1]]<>"_set_"<>ToString[i]<>"_sp_"<>IntegerString[j,10,2]<>"_fit.dat",dummy4,"Table"];
,{j,1,Nsp}];

Do[
dummy3=dummy;
dummy3[[1;;Nsp+Nst]]=Table[0.0,{k,1,Nsp+Nst}];
dummy3[[Nsp+j]]=dummy[[Nsp+j]];
dummy3[[Nsp+Nst+4]]=0.0;
dummy4=Transpose[{#,plsc[[i]]*FF@@{dummy3,fsp[[i]],fst[[i]],Nsp,Nst,#}}&@set[[i]][[All,1]]];
(* do not forget to increase Nst-index by 1 *)
Export[OutDir<>YFile[[1]]<>"_set_"<>ToString[i]<>"_st_"<>IntegerString[j+1,10,2]<>"_fit.dat",dummy4,"Table"];
,{j,1,Nst}];


(* list of plots with fits *)
AppendTo[pexpfitList,ListLogLogPlot[dummy2,Joined->True,PlotStyle->{col[[i,2]],Thick},PlotRange->PlRange,PlotMarkers->{Automatic,Small}]];
,{i,1,Nset}];
pexpfit=Show[pexpfitList,Frame->True,PlotLabel->Style[Framed[ToString[OutDir]<>ToString[YFile[[1]]]],16,Background->LightYellow],ImageSize->3*ImgSizeUnit,DisplayFunction->Identity];

(* create barchart of coefficients c_i and d_i *)
cdList=Labeled[#,ToString[NumberForm[N[Round[#*10^4]/10^4],{5,4}]],Above]&/@PlotArgList[[1;;Nsp+Nst]];
chlList=ParStart[[1;;Nsp+Nst,1]];
chsList=Join[Table[Blue,{i,1,Nsp}],Table[Green,{i,1,Nst}]];
AppendTo[pBarChartList,BarChart[cdList,ChartLabels->chlList,ChartStyle->chsList,Frame->True,FrameTicks->{None, Automatic},ImageSize->ImgSizeUnit]];

(* create barchart for rho and sld *)
Do[
cdList=Labeled[#,ToString[NumberForm[N[Round[#*10^5]/10^5],{4,3}]],Above]&/@PlotArgList[[Nsp+Nst+1+(i-1)*4;;Nsp+Nst+3+(i-1)*4]];
chlList=ParStart[[Nsp+Nst+1+(i-1)*4;;Nsp+Nst+3+(i-1)*4,1]];
chsList=Table[col[[i,2]],{j,1,3}];
AppendTo[pBarChartList,BarChart[cdList,ChartLabels->Placed[chlList,Top],ChartStyle->chsList,Frame->True,FrameTicks->{None, Automatic},PlotRange->{{0.5,3.5},If[Xnmode[[i]]=="X",{250,530},{-0.6,8}]}, AspectRatio->1,ImageSize->3*ImgSizeUnit/Nset]];
,{i,1,Nset}];

(* create final image and export *)
pImg=Grid[{{pexpfit},{GraphicsGrid[{pBarChartList[[2;;]]}]},{pBarChartList[[1]]}},Frame->All,Spacings->0];Export[OutDir<>YFile[[1]]<>".png",pImg,ImageSize->3*ImgSizeUnit];

(* close logfile *)
$Messages=$Messages[[{1}]];
On[General::stop];
Close[stream];

,{Y,1,Length[YFileListLocal]}];(* end (Parallel)Do *)

];


