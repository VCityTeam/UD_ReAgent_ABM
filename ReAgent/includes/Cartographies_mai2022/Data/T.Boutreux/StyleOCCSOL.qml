<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis maxScale="0" version="3.10.11-A Coruña" hasScaleBasedVisibilityFlag="0" styleCategories="AllStyleCategories" minScale="1e+08">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
  </flags>
  <customproperties>
    <property value="false" key="WMSBackgroundLayer"/>
    <property value="false" key="WMSPublishDataSourceUrl"/>
    <property value="0" key="embeddedWidgets/count"/>
    <property value="Value" key="identify/format"/>
  </customproperties>
  <pipe>
    <rasterrenderer alphaBand="-1" opacity="1" band="1" type="paletted">
      <rasterTransparency/>
      <minMaxOrigin>
        <limits>None</limits>
        <extent>WholeRaster</extent>
        <statAccuracy>Estimated</statAccuracy>
        <cumulativeCutLower>0.02</cumulativeCutLower>
        <cumulativeCutUpper>0.98</cumulativeCutUpper>
        <stdDevFactor>2</stdDevFactor>
      </minMaxOrigin>
      <colorPalette>
        <paletteEntry value="6" alpha="255" color="#d34213" label="Bati"/>
        <paletteEntry value="1" alpha="255" color="#d4f6a4" label="Herbacees"/>
        <paletteEntry value="2" alpha="255" color="#82e26d" label="Buissons"/>
        <paletteEntry value="3" alpha="255" color="#009235" label="Arbustes"/>
        <paletteEntry value="4" alpha="255" color="#006b29" label="Petits Arbres"/>
        <paletteEntry value="5" alpha="255" color="#00441b" label="Grands Arbres"/>
        <paletteEntry value="11" alpha="255" color="#70c4ff" label="Eau"/>
        <paletteEntry value="8" alpha="255" color="#ff9932" label="Cultures"/>
        <paletteEntry value="7" alpha="255" color="#fff565" label="Prairies"/>
        <paletteEntry value="10" alpha="255" color="#000000" label="Artificialisé"/>
      </colorPalette>
    </rasterrenderer>
    <brightnesscontrast contrast="0" brightness="0"/>
    <huesaturation colorizeOn="0" saturation="0" colorizeBlue="128" colorizeGreen="128" colorizeRed="255" colorizeStrength="100" grayscaleMode="0"/>
    <rasterresampler maxOversampling="2"/>
  </pipe>
  <blendMode>0</blendMode>
</qgis>
