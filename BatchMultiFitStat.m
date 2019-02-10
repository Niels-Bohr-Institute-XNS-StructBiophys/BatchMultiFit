
Needs["ErrorBarPlots`"];
Get["ErrorBarLogPlots.m"];



Clear[loadexp]
loadexp[file0_,PrintFlag0_:False,PrintFunc0_:Print,smin0_:0,smax0_:Infinity]:=Module[{file=file0,PrintFlag=PrintFlag0,PrintFunc=PrintFunc0,smin=smin0,smax=smax0,exp,dummy,dummy2,th},
exp={};
th=0.01;(*threshold for dI/I*)
Do[If[PrintFlag,PrintFunc@@{"Load file "<>file[[i]]};];
dummy=Import[file[[i]],"Table"];
(*ignore all lines starting with #*)dummy=Drop[dummy[[Max[Position[dummy,"#"][[All,1]]]+1;;,All]],-1];
(*remove empty list elements stemming from empty lines*)dummy=Select[dummy,#!={}&];
(*apply s-filter,usually all points are read*)dummy=Select[dummy,(#[[1]]>=smin&&#[[1]]<=smax)&];
If[Dimensions[dummy][[2]]>4||Dimensions[dummy][[2]]<2,Print["File "<>ToString[file[[i]]]<>" has "<>Dimensions[dummy][[2]]<>" columns. Expected 2-4. Exit."];Exit[];];
If[PrintFlag,PrintFunc@@{"File "<>ToString[file[[i]]]<>" has "<>ToString[Dimensions[dummy][[2]]]<>" columns"};];
If[PrintFlag,PrintFunc@@{"Selected "<>ToString[Length[dummy]]<>" datapoints between s=["<>ToString[smin]<>","<>ToString[smax]<>"]"};];
(*drop non positive datapoints*)dummy=Select[dummy,#[[2]]>0&];
If[PrintFlag,PrintFunc@@{"Selected "<>ToString[Length[dummy]]<>" positive datapoints from that"};];
(*append missing dI and ds error if only 2 columns*)
(*If[Dimensions[dummy][[2]]==2,dummy=MapThread[Append,{dummy,0.01*dummy[[All,2]]}];];*)
If[Dimensions[dummy][[2]]==2,dummy=ArrayFlatten[{{dummy,0.0,0.0}}];];
(*append missing ds error if only 3 columns*)If[Dimensions[dummy][[2]]==3,dummy=ArrayFlatten[{{dummy,0.0}}];];
(*set a minimum for dI in 3rd column*)If[PrintFlag,PrintFunc@@{"Reset dI to dI="<>ToString[th]<>"*I for "<>ToString[Length[Select[dummy,#[[3]]<th*#[[2]]&]]]<>" datapoints"};];
dummy=If[#[[3]]<th*#[[2]],{#[[1]],#[[2]],th*#[[2]],#[[4]]},#]&/@dummy;
(*swap 3rd and 4th colum for internal column format*)If[PrintFlag,PrintFunc@@{"Swapped internally 3rd and 4th column"};];
dummy2=dummy[[All,3]];dummy[[All,3]]=dummy[[All,4]];dummy[[All,4]]=dummy2;
AppendTo[exp,dummy];,{i,1,Length[file]}];
exp];


Clear[DeriveTp];
DeriveTp[files0_,pattlist0_,data0_:{},appendQ0_:False]:=Module[{files=files0,pattlist=pattlist0,data=data0,appendQ=appendQ0,stream,dummy},
(* create {disl,dosl} table *)
If[appendQ==False,data=Table[Flatten[{files[[i]],(*Flatten[{#[[1]]/10^(#[[2]]-2)}]&@*)ToExpression[{#,StringLength[#]}&@StringSplit[StringDrop[StringDrop[StringCases[files[[i]],"_P"~~__~~"_ST"][[1]],2],-3],"_"]][[1]]}],{i,1,Length[files]}];];
(* create list of patterns, the one for T is included automatically if not append *)
If[Length[pattlist]==0,pattlist={pattlist};];
(* Print[pattlist]; *)
(* loop over all files and patterns *)
Do[stream=ToString[InputForm[Import[files[[i]]]]];
Do[
(* Print[ToExpression["{"<>StringCases[StringCases[stream,Shortest[pattlist[[j]]<>" = "~~__~~"\\n"]][[1]]," = "~~x__~~"\\n"->x]<>"}"]+1]; *)
(* grab only first element *) 
dummy=ToExpression["{"<>StringCases[StringCases[stream,Shortest[pattlist[[j]]<>" = "~~__~~"\\n"]][[1]]," = "~~x__~~"\\n"->x]<>"}"][[1]];
AppendTo[data[[i]],dummy];
,{j,1,Length[pattlist]}];
,{i,1,Length[files]}];
data];


(*
{1,2,3,4,...} = { file.log, disl, dosl, T, cis, rhos, chiXn1, <ichi> };
disl, dosl in 2nd and 3rd col;
T in 4th col;

InputForm[Simplify[(a*x+b)/.Solve[{a*minT+b==minG,a*maxT+b==maxG},{a,b}]]]
{(maxT*minG - maxG*minT + maxG*x - minG*x)/(maxT - minT)}
*)
Clear[pT]
pT[data0_,dislmin0_,dislmax0_,ddisl0_,doslmin0_,doslmax0_,ddosl0_,Nsp0_,lablist0_,OptionsPattern[]]:=Module[{data=data0,dislmin=dislmin0,dislmax=dislmax0,ddisl=ddisl0,doslmin=doslmin0,doslmax=doslmax0,ddosl=ddosl0,Nsp=Nsp0,lablist=lablist0,mulist,mu2list,dummy,outdir,maxT,minT,maxG,minG,data2,bestdata,mindata,bestdots,mindot,MeanMedianStDevMinMax,expfile,stream,logstream,expdata,fitdata,plexp,plfit,plbestfit,plminfit,plfitcombo,count,count2,pl,box,plist,boxlist,boxcis,boxrho,boxbestcis,boxbestrho,PlRange,CisPlRange,RhoPlRange,PointSizeDot,n,ticks,dd,plotfiles},

(* dir where log files are stored and pictures are exported to *)
outdir=DirectoryName[data[[1,1]]];

(* remove old files *)
plotfiles=FileNames[outdir<>"fits_*.pdf"];
Do[DeleteFile[plotfiles[[i]]];,{i,1,Length[plotfiles]}];
plotfiles=FileNames[outdir<>"pl_*.pdf"];
Do[DeleteFile[plotfiles[[i]]];,{i,1,Length[plotfiles]}];
plotfiles=FileNames[outdir<>"pl_*.png"];
Do[DeleteFile[plotfiles[[i]]];,{i,1,Length[plotfiles]}];
plotfiles=FileNames[outdir<>"box_*.png"];
Do[DeleteFile[plotfiles[[i]]];,{i,1,Length[plotfiles]}];
plotfiles=FileNames[outdir<>"stat.log"];
Do[DeleteFile[plotfiles[[i]]];,{i,1,Length[plotfiles]}];

(* open log file *)
logstream=OpenWrite[outdir<>"stat.log"];
If[logstream==$Failed,Print["Cannot write log-file "<>outdir<>"stat.log Exit."];Exit[];];

(* mu for a selected T-range *)
mulist=OptionValue[mu];

(* mu2 for a best selected T-range *)
mu2list=OptionValue[mu2];

(* individual grids *)
dd=OptionValue[Ticks];
dd=If[ToString[dd]=="Automatic",{ddosl,ddisl},{dd,dd}];

(* number of cols without filename, should be same as lablist *)
n=Length[data[[1]]]-1;

(* define Min and Max of T *)
maxT=Max[data[[All,4]]];
minT=Min[data[[All,4]]];

(* select those points within a certain T range *)
data=Select[data,(mulist[[1]]*minT+mulist[[2]]*maxT<=#[[4]]<=mulist[[3]]*minT+mulist[[4]]*maxT)&];

(* fields outside the range *)
dummy=Flatten[Table[{i,j},{i,dislmin,dislmax,ddisl},{j,doslmin,doslmax, ddosl}],1];
dummy=Complement[dummy,data[[All,2;;3]]];
dummy=Join@@@Transpose[{dummy,ConstantArray[{-10},Length[dummy]]}];

(* redefine new minT and maxT for mu range *)
maxT=Max[data[[All,4]]];
minT=Min[data[[All,4]]];

(* set markers for best fits mu2 range applies within mu range !!! *)
bestdata=Select[data,(minT<=#[[4]]<=mu2list[[1]]*minT+mu2list[[2]]*maxT)&];

(* Determine mindata *)
mindata=Select[data,(#[[4]]==minT)&];

WriteString[logstream,"Length[data] = "<>ToString[Length[data]]<>"\n"];
WriteString[logstream,"Length[bestdata] = "<>ToString[Length[bestdata]]<>"\n"];
WriteString[logstream,"Length[mindata] = "<>ToString[Length[mindata]]<>"\n"];
WriteString[logstream,"\n"];

WriteString[logstream,"params = "<>ToString[Join[{"filename"},lablist]]<>"\n\n"];

(* calc Mean and Var from data, bestdata, mindata and write to logfile *)
WriteString[logstream,"stat ={Mean, Median, StandardDev, Min, Max}"<>"\n\n"];

WriteString[logstream,"data ("<>ToString[Length[data]]<>" fits):\n"];
MeanMedianStDevMinMax=If[Length[data]>1,
Table[{Mean[#],Median[#],StandardDeviation[#],Min[#],Max[#]}&@data[[All,1+k]],{k,1,n}],
Table[{#[[1]],#[[1]],0,#[[1]],#[[1]]}&@data[[All,1+k]],{k,1,n}]
];
Do[WriteString[logstream,lablist[[k]]<>" = "<>ToString[MeanMedianStDevMinMax[[k]]]<>"\n"],{k,1,n}];
WriteString[logstream,"\n"];

WriteString[logstream,"bestdata ("<>ToString[Length[bestdata]]<>" fits):\n"];
MeanMedianStDevMinMax=If[Length[bestdata]>1,
Table[{Mean[#],Median[#],StandardDeviation[#],Min[#],Max[#]}&@bestdata[[All,1+k]],{k,1,n}],
Table[{#[[1]],#[[1]],0,#[[1]],#[[1]]}&@bestdata[[All,1+k]],{k,1,n}]
];
Do[WriteString[logstream,lablist[[k]]<>" = "<>ToString[MeanMedianStDevMinMax[[k]]]<>"\n"],{k,1,n}];
WriteString[logstream,"\n"];

(* WriteString[logstream,"mindata = "<>ToString[mindata[[1]]]<>"\n\n"]; *)
WriteString[logstream,"mindata ("<>ToString[Length[mindata]]<>" fits):\n"];
MeanMedianStDevMinMax=If[Length[mindata]>1,
Table[{Mean[#],Median[#],StandardDeviation[#],Min[#],Max[#]}&@mindata[[All,1+k]],{k,1,n}],
Table[{#[[1]],#[[1]],0,#[[1]],#[[1]]}&@mindata[[All,1+k]],{k,1,n}]
];
Do[WriteString[logstream,lablist[[k]]<>" = "<>ToString[MeanMedianStDevMinMax[[k]]]<>"\n"],{k,1,n}];
WriteString[logstream,"\n"];

(* Point radius {r_x,r_y} for black and white dots, adapt automatically to grid *)
PointSizeDot=OptionValue[PointSize];
If[PointSizeDot=="Automatic",PointSizeDot=dd/8.0;];

(* best and min data dots *)
(* bestdots=Graphics[{Black,AbsolutePointSize[PointSizeDot],Point[#[[2;;3]]]&/@bestdata}]; *)
bestdots=Table[Graphics[{Black,Disk[bestdata[[i,2;;3]],PointSizeDot]}],{i,1,Length[bestdata]}];
mindot=Table[Graphics[{White,Disk[mindata[[i,2;;3]],PointSizeDot]}],{i,1,Length[mindata]}];

(* full data + s-restricted fits, plot all fits *)
stream=ToString[InputForm[Import[data[[1,1]]]]]; (* exp data set from first log file derived *)
expfile="export/"<>StringCases[StringCases[stream,Shortest["Load file export/"~~__~~"\\n"]][[1]],"export/"~~x__~~"\\n"->x][[1]];
expdata=loadexp[{expfile},False, Print][[1]];
plexp=ErrorListLogLogPlot[{{#[[1]],#[[2]]},ErrorBar[0*#[[3]],#[[4]]]}&/@expdata,Joined->False,PlotStyle->{Green,Thin},DisplayFunction->Identity];

plfit=Table[,{i,1,Length[data]}];
plbestfit=Table[,{i,1,Length[bestdata]}];
minG=0.0;maxG=0.8;

Do[
fitdata=Import[StringReplace[data[[i,1]],".log"->"_set_1_fit.dat"],"Table"];
plfit[[i]]=ListLogLogPlot[fitdata,Joined->True,PlotStyle->{Thin,Opacity[0.5],Red},DisplayFunction->Identity];
,{i,1,Length[data]}];
Do[
fitdata=Import[StringReplace[bestdata[[i,1]],".log"->"_set_1_fit.dat"],"Table"];
plbestfit[[i]]=ListLogLogPlot[fitdata,Joined->True,PlotStyle->{Opacity[1],GrayLevel[(maxT*minG-maxG*minT+(maxG-minG)*Tpdata[[i,4]])/(maxT-minT)]},DisplayFunction->Identity];
,{i,1,Length[bestdata]}];
fitdata=Import[StringReplace[mindata[[1,1]],".log"->"_set_1_fit.dat"],"Table"];
plminfit=ListLogLogPlot[fitdata,Joined->True,PlotStyle->{Yellow},DisplayFunction->Identity];

(* Export data with fits *)
plfitcombo=Show[{plexp,plfit,plbestfit,plminfit},FrameLabel->{"s=Q/2Pi [1/nm]","I [1/cm]"},Frame->True,FrameStyle->Directive[4*OptionValue[PlotFontSize],Black],PlotLabel->Style["fits in "<>outdir,4*OptionValue[PlotFontSize],Black]];
Export[outdir<>"pl_fits_all_best_min.png",plfitcombo,"PNG",ImageSize->4*OptionValue[ImageSize]];

plfitcombo=Show[{plexp,plfit,plbestfit,plminfit},FrameLabel->{"s=Q/2Pi [1/nm]","I [1/cm]"},Frame->True,PlotLabel->Style["fits in "<>outdir]];
Export[outdir<>"pl_fits_all_best_min.pdf",plfitcombo,"PDF",ImageResolution->300];

Do[
fitdata=Import[StringReplace[bestdata[[i,1]],".log"->"_set_1_fit.dat"],"Table"];
plbestfit[[i]]=ListLogLogPlot[fitdata,Joined->True,PlotStyle->{Opacity[1],GrayLevel[0]},DisplayFunction->Identity];,{i,1,Length[bestdata]}];

plfitcombo=Show[{plexp,plfit,plbestfit,plminfit},FrameLabel->{"s=Q/2Pi [1/nm]","I [1/cm]"},Frame->True,FrameStyle->Directive[4*OptionValue[PlotFontSize],Black],PlotLabel->Style["fits in "<>outdir,4*OptionValue[PlotFontSize],Black]];
Export[outdir<>"pl_fits_all_best_min_easy.png",plfitcombo,"PNG",ImageSize->4*OptionValue[ImageSize]];

plfitcombo=Show[{plexp,plfit,plbestfit,plminfit},FrameLabel->{"s=Q/2Pi [1/nm]","I [1/cm]"},Frame->True,PlotLabel->Style["fits in "<>outdir]];
Export[outdir<>"pl_fits_all_best_min_easy.pdf",plfitcombo,"PDF",ImageResolution->300];

(* plot arrangement for notebook *)
plist=Table[,{i,1,Ceiling[n,3]/3},{j,1,Min[3,n-(i-1)*3]}];
boxlist=Table[,{i,1,Ceiling[n,3]/3},{j,1,Min[3,n-(i-1)*3]}];

(* ticks *)
ticks={{(If[!IntegerQ[#],#+0.0,#])&/@Range[doslmin,doslmax,dd[[2]]],None},{{#,Rotate[ToString[#],90Degree],{0,0.01}}&/@(If[!IntegerQ[#],#+0.0,#]&/@Range[dislmin,dislmax,dd[[1]]]),None}};


(* 2D pl maps for individual fit parameters, excl single ci *)
(* loop over k=1,..,n *)
count=1;count2=1;
Do[

If[(k==3)||(k>(3+Nsp)),
(* range for current plot *)
maxT=Max[data[[All,1+k]]];
minT=Min[data[[All,1+k]]];
data2=Join[data[[All,{2,3,1+k}]],dummy];
(* background plot for mu-range selection *)
(* instead of PlotLegends->Automatic one could also play around with PlotLegends->BarLegend[...] with more styling options *)
pl=ListDensityPlot[data2,InterpolationOrder->0,FrameTicks->ticks,FrameStyle->Directive[1.5*OptionValue[PlotFontSize],Black],FrameLabel->{"disl (A)","dosl (A)"},ClippingStyle->White,ColorFunction->(Hue[0.7*(1-(#-minT)/(maxT-minT+0.000001))]&),ColorFunctionScaling->False,PlotRange->{{dislmin-ddisl/2,dislmax+ddisl/2},{doslmin-ddosl/2,doslmax+ddosl/2},{minT-0.000001,maxT+0.000001}},BoundaryStyle->Black,ImageSize->OptionValue[ImageSize],PlotLegends->BarLegend[Automatic,LegendFunction->"Frame",LegendMargins->10,LabelStyle->{FontSize->28}],PlotLabel->Style[StringReplace[lablist[[k]]," "->"_"],1.5*OptionValue[PlotFontSize],Black]];
pl=Show[Join[{pl},bestdots,mindot],ImageSize->OptionValue[ImageSize]];
plist[[count2,count]]=pl;
Export[outdir<>"pl_"<>StringReplace[lablist[[k]]," "->"_"]<>".png",pl,"PNG",ImageSize->OptionValue[ImageSize]];

count=count+1;
If[count>3,count=1;count2+=1;];
];

,{k,1,n}];

(* WhiskerBox plots for individual fit parameters, excl single ci and rho *)
(* loop over k=1,..,n *)
count=1;count2=1;
Do[

If[(k==3)||(k>(3+Nsp+3)),
(* PlotRange for WhiskerBox plots *)
PlRange={0.97*Min[#],1.03*Max[#]}&@data[[All,1+k]];
(* min point for individual WhiskerBox plots done via Epilog, combination of ListPlot and BoxWhiskerChart works only in Mathematica < 11.3 *)
(* plmin=ListPlot[{mindata[[1,1+k]]},PlotStyle->{Red,PointSize[Large]}]; *)
box=BoxWhiskerChart[data[[All,1+k]],"Mean",ChartLabels->lablist[[k]],FrameStyle->Directive[OptionValue[PlotFontSize],Black],PlotLabel->Style[StringReplace[lablist[[k]]<>" all"," "->"_"],OptionValue[PlotFontSize],Black],GridLines->{None,Automatic},BarSpacing->1,Epilog->{Red,PointSize[0.01],Point[{0.75,mindata[[1,1+k]]}]}];
Export[outdir<>"box_"<>StringReplace[lablist[[k]]," "->"_"]<>"_all.png",Show[box,PlotRange->PlRange],"PNG",ImageSize->OptionValue[ImageSize]];
(* WhiskerBox stat plots for bestdata *)
box=BoxWhiskerChart[bestdata[[All,1+k]],"Mean",ChartLabels->lablist[[k]],FrameStyle->Directive[OptionValue[PlotFontSize],Black],PlotLabel->Style[StringReplace[lablist[[k]]<>" best"," "->"_"],OptionValue[PlotFontSize],Black],GridLines->{None,Automatic},BarSpacing->1,Epilog->{Red,PointSize[0.01],Point[{0.75,mindata[[1,1+k]]}]}];
Export[outdir<>"box_"<>StringReplace[lablist[[k]]," "->"_"]<>"_best.png",Show[box,PlotRange->PlRange],"PNG",ImageSize->OptionValue[ImageSize]];
boxlist[[count2,count]]=box;

count=count+1;
If[count>3,count=1;count2+=1;];
];

,{k,1,n}];

(* all stuff derived / gathered from fit parameters *)
CisPlRange={0.97*Min[#],1.03*Max[#]}&@data[[All,4+1;;4+Nsp]];(*OptionValue[CisPlotRange];*)
RhoPlRange={0.97*Min[#],1.03*Max[#]}&@data[[All,4+Nsp+1;;4+Nsp+3]];(*OptionValue[RhosPlotRange];*)

boxcis=BoxWhiskerChart[Transpose[data[[All,4+1;;4+Nsp]]],"Mean",ChartLabels->lablist[[1+1;;1+Nsp]],(*{{"MedianMarker",White},{"MeanMarker",Black},{"Whiskers",Thick},{"Fences",Thick}},*)FrameStyle->Directive[1.5*OptionValue[PlotFontSize],Black],PlotLabel->Style["cis all",1.5*OptionValue[PlotFontSize],Black],ChartStyle->{Opacity[1]},Joined->True,GridLines->{None,Automatic},BarSpacing->1,Epilog->{Red,PointSize[0.01],Point[Table[{i-1+0.75,mindata[[1,4+i]]},{i,1,Nsp}]]}];

boxbestcis=BoxWhiskerChart[Transpose[bestdata[[All,4+1;;4+Nsp]]],"Mean",FrameStyle->Directive[1.5*OptionValue[PlotFontSize],Black],PlotLabel->Style["cis best",1.5*OptionValue[PlotFontSize],Black],ChartLabels->lablist[[1+1;;1+Nsp]],ChartStyle->{Opacity[1]},Joined->True,GridLines->{None,Automatic},BarSpacing->1,Epilog->{Red,PointSize[0.01],Point[Table[{i-1+0.75,mindata[[1,4+i]]},{i,1,Nsp}]]}];

boxrho=BoxWhiskerChart[Transpose[data[[All,4+Nsp+1;;4+Nsp+3]]],"Mean",FrameStyle->Directive[1.5*OptionValue[PlotFontSize],Black],PlotLabel->Style["rho all",1.5*OptionValue[PlotFontSize],Black],ChartLabels->lablist[[1+Nsp+1;;1+Nsp+3]],ChartStyle->{Opacity[1]},Joined->True,GridLines->{None,Automatic},BarSpacing->1,Epilog->{Red,PointSize[0.01],Point[Table[{i-1+0.75,mindata[[1,4+Nsp+i]]},{i,1,Nsp}]]}];

boxbestrho=BoxWhiskerChart[Transpose[bestdata[[All,4+Nsp+1;;4+Nsp+3]]],"Mean",FrameStyle->Directive[1.5*OptionValue[PlotFontSize],Black],PlotLabel->Style["rhos best",1.5*OptionValue[PlotFontSize],Black],ChartLabels->lablist[[1+Nsp+1;;1+Nsp+3]],ChartStyle->{Opacity[1]},Joined->True,GridLines->{None,Automatic},BarSpacing->1,Epilog->{Red,PointSize[0.01],Point[Table[{i-1+0.75,mindata[[1,4+Nsp+i]]},{i,1,Nsp}]]}];

Export[outdir<>"box_cis_best.png",Show[boxbestcis,PlotRange->CisPlRange],(*"PDF",ImageResolution->300*)"PNG",ImageSize->1.5*OptionValue[ImageSize]];
Export[outdir<>"box_rho_best.png",Show[boxbestrho,PlotRange->RhoPlRange],(*"PDF",ImageResolution->300*)"PNG",ImageSize->1.5*OptionValue[ImageSize]];
Export[outdir<>"box_cis_all.png",Show[boxcis,PlotRange->CisPlRange],(*"PDF",ImageResolution->300*)"PNG",ImageSize->1.5*OptionValue[ImageSize]];
Export[outdir<>"box_rho_all.png",Show[boxrho,PlotRange->RhoPlRange],(*"PDF",ImageResolution->300*)"PNG",ImageSize->1.5*OptionValue[ImageSize]];

Close[logstream];

(*{plfitcombo,Grid[plist],Grid[boxlist],Grid[{{boxbestcis},{boxbestrho}}]}*)];
Options[pT]={mu->{1,0,0,1},mu2->{1.1,0},PointSize->"Automatic"(*{1.0,1.0}*),Ticks->"Automatic",ImageSize->1024,PlotFontSize->18(*for 1024 ImageSize*),RhosPlotRange->{270,400},CisPlotRange->{0,0.5}};


