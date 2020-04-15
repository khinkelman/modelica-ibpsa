within IBPSA.BoundaryConditions.BESTEST.Validation;
model WD200  "Test model for BESTEST weather data: Low Elevation, Hot and Humid Case"
  extends WD100(lat= 0.58700658732325,  rho = 0, alt = 308);
  annotation (Documentation(revisions="<html>
<ul>
<li>
March 11, 2020, by Ettore Zanetti:<br/>
First implementation.
</li>
<li>
April 14, 2020, by Ettore Zanetti:<br/>
Rework after comments from pull request
<a href=\"https://github.com/ibpsa/modelica-ibpsa/pull/1339\">#1339</a>.
</li>
</ul>
</html>", info="<html>
<h4>WD200: Low Elevation, Hot and Humid Case.</h4>
<p>Weather data file : 722190.epw</p>
<p><i>Table 1: Site Data for Weather file 722190.epw</i></p>
<table cellspacing=\"2\" cellpadding=\"0\" border=\"1\"><tr>
<td><p>Latitude</p></td>
<td><p>33.633&deg; north</p></td>
</tr>
<tr>
<td><p>Longitude</p></td>
<td><p>84.433&deg; west</p></td>
</tr>
<tr>
<td><p>Altitude</p></td>
<td><p>308 m</p></td>
</tr>
<tr>
<td><p>Time Zone</p></td>
<td><p>5</p></td>
</tr>
</table>
</html>"));
end WD200;
