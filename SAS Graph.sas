ods graphics / attrpriority=color imagename='UpSet';
libname a  "/data01/sherwin/Data";

data plotdata;
	merge a.intersection_size a.covar_set_size a.matrix;
run;

proc template;
	define statgraph mygraph;
		begingraph;
			entrytitle halign=left "UpSet Plot";
			entryfootnote halign=right "Created Using GTL";
			DiscreteAttrVar attrvar=MYID_VALUE var=VALUE attrmap="__ATTRMAP__MYID";
			DiscreteAttrVar attrvar=MYID_JOIN var=JOIN attrmap="__ATTRMAP__MYID";
			DiscreteAttrVar attrvar=MYID_GROUP var=GROUP attrmap="__ATTRMAP__MYID";
			DiscreteAttrMap name="__ATTRMAP__MYID" /;
				Value "0" / markerattrs=( color=CXD3D3D3) lineattrs=( thickness=0);
				Value "1" / markerattrs=( color=CX000000) lineattrs=( thickness=2);
				Value "Treatment" / fillattrs=( color=BIBG);
				Value "Placebo" / fillattrs=( color=BIGB);
			EndDiscreteAttrMap;
			layout lattice / rows=2 columns=2 rowweights=(0.7 0.3) columnweights=(0.2 0.8);
				cell;
					entry "";
				endcell;
				cell;
					layout overlay / border=false walldisplay=none xaxisopts=(display=none) yaxisopts=(label="Intersection Size");
						Barchart X='xlabel1'n Y='count1'n / display=(fill) barlabel=true
							Group=MYID_GROUP NAME="BAR1" groupdisplay=stack includemissinggroup=False;
						discretelegend "BAR1" / border=False location=inside autoalign=(topright);
					endlayout;
				endcell;
				cell;
					layout overlay / border=false walldisplay=none xaxisopts=(reverse=True label="Total") y2axisopts=(display=none);
						Barchart X='xlabel2'n Y='count2'n / display=(fill) displaybaseline=off fillattrs=(color=orange)
							NAME="BAR2" orient=horizontal yaxis=y2;
					endlayout;
				endcell;
				cell;
					layout overlay / border=false walldisplay=none 
						yaxisopts=(display=(tickvalues) discreteopts=(colorbands=odd colorbandsattrs=(color=lightgray transparency=0.6))) 
						xaxisopts=(display=none );
						ScatterPlot X='xlabel3'n Y='ylabel3'n / subpixel=off primary=true 
							Group=MYID_VALUE Markerattrs=( Symbol=CIRCLEFILLED Size=12) 
							LegendLabel="ylabel3" 
							NAME="SCATTER";
						SeriesPlot X='xlabel3'n Y='ylabel3'n / Group=MYID_JOIN 
							Lineattrs=( Color=CX000000) LegendLabel="ylabel3" 
							NAME="SERIES";
					endlayout;
				endcell;
			endlayout;
		endgraph;
	end;
run;

proc sgrender data=plotdata template=mygraph;
run;
