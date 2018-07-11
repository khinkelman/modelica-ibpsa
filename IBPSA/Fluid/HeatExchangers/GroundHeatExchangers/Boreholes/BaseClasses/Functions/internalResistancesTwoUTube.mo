within IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Boreholes.BaseClasses.Functions;
function internalResistancesTwoUTube
  "Thermal resistances for double U-tube, according to Zeng et al. (2003) and Bauer et al (2010)"
  extends
    IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Boreholes.BaseClasses.Functions.partialInternalResistances;

  // Outputs
  output Modelica.SIunits.ThermalResistance Rgb
    "Thermal resistance between a grout capacity and the borehole wall, as defined by Bauer et al (2010)";
  output Modelica.SIunits.ThermalResistance Rgg1
    "Thermal resistance between two neightbouring grout capacities, as defined by Bauer et al (2010)";
  output Modelica.SIunits.ThermalResistance Rgg2
    "Thermal resistance between two  grout capacities opposite to each other, as defined by Bauer et al (2010)";
  output Modelica.SIunits.ThermalResistance RCondGro
    "Thermal resistance between a pipe wall and the grout capacity, as defined by Bauer et al (2010)";
protected
  Real[4,4] RDelta "Delta-circuit thermal resistances";
  Real[4,4] R "Internal thermal resistances";
  Real[4] xPip = {-sha, sha, 0., 0.} "x-Coordinates of pipes";
  Real[4] yPip = {0., 0., -sha, sha} "y-Coordinates of pipes";
  Real[4] rPip = {rTub, rTub, rTub, rTub} "Outer radius of pipes";
  Real[4] RFluPip(unit="(m.K)/W") = {RCondPipe+RConv, RCondPipe+RConv, RCondPipe+RConv, RCondPipe+RConv} "Fluid to pipe wall thermal resistances";

  Real Ra( unit="(m.K)/W");

  Modelica.SIunits.ThermalResistance Rg;
  Modelica.SIunits.ThermalResistance Rar1;
  Modelica.SIunits.ThermalResistance Rar2;

algorithm
  // Internal thermal resistances
  (RDelta, R) :=
    IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Boreholes.BaseClasses.Functions.multipoleThermalResistances(
      4, 3, xPip, yPip, rBor, rPip, kFil, kSoi, RFluPip);

  // Rb and Ra
  Rb_internal :=if use_Rb then Rb else 1./(1./RDelta[1,1] + 1./RDelta[2,2] + 1./RDelta[3,3] + 1./RDelta[4,4]);
  Ra := R[1,1] + R[3,3] - 2*R[1,3];

  // ------ Calculation according to Bauer et al. (2010)
  Rg := (4*Rb_internal - RCondPipe - RConv)/hSeg;
  Rar1 := ((2 + sqrt(2))*Rg*hSeg*(Ra - RCondPipe)/(Rg*hSeg + Ra - RCondPipe))/hSeg;
  Rar2 := sqrt(2)*Rar1;

  // If any of the internal delta-circuit resistances is negative, then
  // the location (x) of the thermal capacity is set to zero to limit
  // instabilities in the calculations. Otherwise, calculations follow the
  // method of Bauer et al. (2011).
  if (RDelta[1,2] < 0) or (RDelta[1,3] < 0) then
    //Thermal resistance between the grout zone and bore hole wall
    Rgb := Rg;

    //Conduction resistance in grout from pipe wall to capacity in grout
    RCondGro := RCondPipe/hSeg;

    //Thermal resistance between the two grout zones
    Rgg1 := 2*Rgb*(Rar1)/(2*Rgb - Rar1);
    Rgg2 := 2*Rgb*(Rar2)/(2*Rgb - Rar2);

    test := true;
  else
    // ********** Resistances and capacity location according to Bauer **********
    while test == false and i <= 16 loop
      // Capacity location (with correction factor in case that the test is negative)
      x := Modelica.Math.log(sqrt(rBor^2 + 4*rTub^2)/(2*sqrt(2)*rTub))/
          Modelica.Math.log(rBor/(2*rTub))*((15 - i + 1)/15);

      //Thermal resistance between the grout zone and bore hole wall
      Rgb := (1 - x)*Rg;

      //Conduction resistance in grout from pipe wall to capacity in grout
      RCondGro := x*Rg + RCondPipe/hSeg;

      //Thermal resistance between the two grout zones
      Rgg1 := 2*Rgb*(Rar1 - 2*x*Rg)/(2*Rgb - Rar1 + 2*x*Rg);
      Rgg2 := 2*Rgb*(Rar2 - 2*x*Rg)/(2*Rgb - Rar2 + 2*x*Rg);

      // Thermodynamic test to check if negative R values make sense. If not, decrease x-value.
      // fixme: the implemented is only for single U-tube BHE's.
     test := (((1/Rgg1 + 1/2/Rgb)^(-1) > 0) and ((1/Rgg2 + 1/2/Rgb)^(-1) > 0));
      i := i + 1;
    end while;
  end if;
  assert(test,
  "Maximum number of iterations exceeded. Check the borehole geometry.
  The tubes may be too close to the borehole wall.
  Input to the function
  IBPSA.Fluid.HeatExchangers.Boreholes.BaseClasses.doubleUTubeResistances
  is
            hSeg = " + String(hSeg) + " m
            rBor = " + String(rBor) + " m
            rTub = " + String(rTub) + " m
            eTub = " + String(eTub) + " m
            sha = " + String(sha) + " m
            kSoi = " + String(kSoi) + " W/m/K
            kFil = " + String(kFil) + " W/m/K
            kTub = " + String(kTub) + " W/m/K
  Computed x    = " + String(x) + " m
            Rgb  = " + String(Rgb) + " K/W
            Rgg1  = " + String(Rgg1) + " K/W
            Rgg2  = " + String(Rgg2) + " K/W");

  if printDebug then
    Modelica.Utilities.Streams.print("
      Rb = " + String(Rb_internal) + " m K / W
      RCondPipe = "+ String(RCondPipe) + " m K / W
      RConv = " +String(RConv) +"m K / W
      hSeg = " + String(hSeg) + " m
      Rg = "+String(Rg) + " K / W
      Ra = " + String(Ra)  + " m K / W
      x = " + String(x) + "
      i = "  + String(i));
  end if;
  annotation (Diagram(graphics), Documentation(info="<html>
<p>
This model computes the different thermal resistances present in a single-U-tube borehole 
using the method of Bauer et al. [1].
It also computes the fluid-to-ground thermal resistance <i>R<sub>b</sub></i> 
and the grout-to-grout thermal resistance <i>R<sub>a</sub></i> 
as defined by Hellstroem [2] using the multipole method.
</p>
<p>
The figure below shows the thermal network set up by Bauer et al.
</p>
<p align=\"center\">
<img alt=\"image\" src=\"E:/work\\modelica/DaPModels/Images/Documentation/Bauer_singleUTube_small.png\"/>
</p>
<p>
The different resistances are calculated with following equations:</p>
<p align=\"center\">
<img alt=\"image\" src=\"E:/work\\modelica/DaPModels/Images/Documentation/Bauer_resistanceValues.PNG\"/>
</p>
<p>
Notice that each resistance each resistance still needs to be divided by 
the height of the borehole segment <i>h<sub>Seg</sub></i>.
</p>
<p>
The fluid-to-ground thermal resistance <i>R<sub>b</sub></i> and the grout-to-grout resistance <i>R<sub>a</sub></i> 
are calculated with the multipole method (Hellstroem (1991)) shown below.
</p>
<p>
<!-- If this is an equation, it needs to be typed, not an image -->
<img alt=\"image\" src=\"E:/work\\modelica/DaPModels/Images/Documentation/Rb_multipole.png\"/>
</p>
<p>
<!-- If this is an equation, it needs to be typed, not an image -->
<img alt=\"image\" src=\"E:/work\\modelica/DaPModels/Images/Documentation/Ra_multipole.png\"/>
</p>
<p>
where 
<!-- fixme: use greek symbols such as &lambda; -->
<i>lambda<sub>b</sub></i> and <i>lambda</i>are the conductivity of the filling material 
and of the ground respectively, 
<i>r<sub>p</sub></i> and <i>r<sub>b</sub></i> 
are the pipe and the borehole radius, 
<i>D</i> is the shank spacing (center of borehole to center of pipe), 
<i>R<sub>p</sub></i> is resistance from the fluid to the outside wall of the pipe, 
<i>r<sub>c</sub></i> is the radius at which the ground temperature is radially uniform and 
<i>Epsilon</i> can be neglected as it is close to zero.
</p>
<h4>References</h4>
<p>G. Hellstr&ouml;m. 
<i>Ground heat storage: thermal analyses of duct storage systems (Theory)</i>. 
Dept. of Mathematical Physics, University of Lund, Sweden, 1991.
</p>
<p>D. Bauer, W. Heidemann, H. M&uuml;ller-Steinhagen, and H.-J. G. Diersch. 
<i>Thermal resistance and capacity models for borehole heat exchangers</i>. 
International Journal Of Energy Research, 35:312&ndash;320, 2010.</p>
</html>", revisions="<html>
<p>
<ul>
<li>
February 14, 2014 by Michael Wetter:<br/>
Added an assert statement to test for non-physical values.
</li>
<li>
February 12, 2014, by Damien Picard:<br/>
Remove the flow dependency of the resistances, as this function calculates the conduction resistances only.
</li>
<li>
January 24, 2014, by Michael Wetter:<br/>
Revised implementation.
</li>
<li>
January 23, 2014, by Damien Picard:<br/>
First implementation.
</li>
</ul></p>
</html>"));
end internalResistancesTwoUTube;
