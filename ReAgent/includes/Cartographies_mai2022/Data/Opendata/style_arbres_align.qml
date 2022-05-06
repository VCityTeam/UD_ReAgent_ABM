<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.16.11-Hannover" simplifyDrawingHints="0" simplifyAlgorithm="0" simplifyLocal="1" simplifyMaxScale="1" readOnly="0" styleCategories="AllStyleCategories" hasScaleBasedVisibilityFlag="0" maxScale="0" simplifyDrawingTol="1" minScale="100000000" labelsEnabled="0">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
  </flags>
  <temporal startExpression="" fixedDuration="0" enabled="0" durationField="" mode="0" endField="" endExpression="" accumulate="0" durationUnit="min" startField="">
    <fixedRange>
      <start></start>
      <end></end>
    </fixedRange>
  </temporal>
  <renderer-v2 radius="25" max_value="0" quality="1" enableorderby="0" weight_expression="" type="heatmapRenderer" radius_unit="0" forceraster="0" radius_map_unit_scale="3x:0,0,0,0,0,0">
    <colorramp type="gradient" name="[source]">
      <prop k="color1" v="255,255,255,255"/>
      <prop k="color2" v="0,68,27,255"/>
      <prop k="discrete" v="0"/>
      <prop k="rampType" v="gradient"/>
      <prop k="stops" v="0.13;229,245,224,255:0.26;199,233,192,255:0.39;161,217,155,255:0.52;116,196,118,255:0.65;65,171,93,255:0.78;35,139,69,255:0.9;0,109,44,255"/>
    </colorramp>
  </renderer-v2>
  <customproperties>
    <property key="embeddedWidgets/count" value="0"/>
    <property key="variableNames"/>
    <property key="variableValues"/>
  </customproperties>
  <blendMode>0</blendMode>
  <featureBlendMode>0</featureBlendMode>
  <layerOpacity>1</layerOpacity>
  <SingleCategoryDiagramRenderer diagramType="Histogram" attributeLegend="1">
    <DiagramCategory penAlpha="255" rotationOffset="270" spacingUnitScale="3x:0,0,0,0,0,0" scaleDependency="Area" spacingUnit="MM" width="15" minScaleDenominator="0" backgroundAlpha="255" penColor="#000000" scaleBasedVisibility="0" enabled="0" spacing="5" height="15" lineSizeType="MM" showAxis="1" opacity="1" penWidth="0" sizeType="MM" labelPlacementMethod="XHeight" barWidth="5" diagramOrientation="Up" sizeScale="3x:0,0,0,0,0,0" lineSizeScale="3x:0,0,0,0,0,0" minimumSize="0" direction="0" maxScaleDenominator="1e+08" backgroundColor="#ffffff">
      <fontProperties description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style=""/>
      <attribute field="" label="" color="#000000"/>
      <axisSymbol>
        <symbol force_rhr="0" clip_to_extent="1" type="line" name="" alpha="1">
          <layer enabled="1" pass="0" class="SimpleLine" locked="0">
            <prop k="align_dash_pattern" v="0"/>
            <prop k="capstyle" v="square"/>
            <prop k="customdash" v="5;2"/>
            <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="customdash_unit" v="MM"/>
            <prop k="dash_pattern_offset" v="0"/>
            <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="dash_pattern_offset_unit" v="MM"/>
            <prop k="draw_inside_polygon" v="0"/>
            <prop k="joinstyle" v="bevel"/>
            <prop k="line_color" v="35,35,35,255"/>
            <prop k="line_style" v="solid"/>
            <prop k="line_width" v="0.26"/>
            <prop k="line_width_unit" v="MM"/>
            <prop k="offset" v="0"/>
            <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="offset_unit" v="MM"/>
            <prop k="ring_filter" v="0"/>
            <prop k="tweak_dash_pattern_on_corners" v="0"/>
            <prop k="use_custom_dash" v="0"/>
            <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <data_defined_properties>
              <Option type="Map">
                <Option type="QString" name="name" value=""/>
                <Option name="properties"/>
                <Option type="QString" name="type" value="collection"/>
              </Option>
            </data_defined_properties>
          </layer>
        </symbol>
      </axisSymbol>
    </DiagramCategory>
  </SingleCategoryDiagramRenderer>
  <DiagramLayerSettings placement="0" priority="0" obstacle="0" zIndex="0" showAll="1" linePlacementFlags="18" dist="0">
    <properties>
      <Option type="Map">
        <Option type="QString" name="name" value=""/>
        <Option name="properties"/>
        <Option type="QString" name="type" value="collection"/>
      </Option>
    </properties>
  </DiagramLayerSettings>
  <geometryOptions removeDuplicateNodes="0" geometryPrecision="0">
    <activeChecks/>
    <checkConfiguration/>
  </geometryOptions>
  <legend type="default-vector"/>
  <referencedLayers/>
  <fieldConfiguration>
    <field name="essencefrancais" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="circonference_cm" configurationFlags="None">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="hauteurtotale_m" configurationFlags="None">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="hauteurfut_m" configurationFlags="None">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="diametrecouronne_m" configurationFlags="None">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="rayoncouronne_m" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="dateplantation" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="genre" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="espece" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="variete" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="essence" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="architecture" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="localisation" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="naturerevetement" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="mobilierurbain" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="anneeplantation" configurationFlags="None">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="commune" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="codeinsee" configurationFlags="None">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="nomvoie" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="codefuv" configurationFlags="None">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="identifiant" configurationFlags="None">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="numero" configurationFlags="None">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="codegenre" configurationFlags="None">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="gid" configurationFlags="None">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="surfacecadre_m2" configurationFlags="None">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias index="0" name="" field="essencefrancais"/>
    <alias index="1" name="" field="circonference_cm"/>
    <alias index="2" name="" field="hauteurtotale_m"/>
    <alias index="3" name="" field="hauteurfut_m"/>
    <alias index="4" name="" field="diametrecouronne_m"/>
    <alias index="5" name="" field="rayoncouronne_m"/>
    <alias index="6" name="" field="dateplantation"/>
    <alias index="7" name="" field="genre"/>
    <alias index="8" name="" field="espece"/>
    <alias index="9" name="" field="variete"/>
    <alias index="10" name="" field="essence"/>
    <alias index="11" name="" field="architecture"/>
    <alias index="12" name="" field="localisation"/>
    <alias index="13" name="" field="naturerevetement"/>
    <alias index="14" name="" field="mobilierurbain"/>
    <alias index="15" name="" field="anneeplantation"/>
    <alias index="16" name="" field="commune"/>
    <alias index="17" name="" field="codeinsee"/>
    <alias index="18" name="" field="nomvoie"/>
    <alias index="19" name="" field="codefuv"/>
    <alias index="20" name="" field="identifiant"/>
    <alias index="21" name="" field="numero"/>
    <alias index="22" name="" field="codegenre"/>
    <alias index="23" name="" field="gid"/>
    <alias index="24" name="" field="surfacecadre_m2"/>
  </aliases>
  <defaults>
    <default applyOnUpdate="0" expression="" field="essencefrancais"/>
    <default applyOnUpdate="0" expression="" field="circonference_cm"/>
    <default applyOnUpdate="0" expression="" field="hauteurtotale_m"/>
    <default applyOnUpdate="0" expression="" field="hauteurfut_m"/>
    <default applyOnUpdate="0" expression="" field="diametrecouronne_m"/>
    <default applyOnUpdate="0" expression="" field="rayoncouronne_m"/>
    <default applyOnUpdate="0" expression="" field="dateplantation"/>
    <default applyOnUpdate="0" expression="" field="genre"/>
    <default applyOnUpdate="0" expression="" field="espece"/>
    <default applyOnUpdate="0" expression="" field="variete"/>
    <default applyOnUpdate="0" expression="" field="essence"/>
    <default applyOnUpdate="0" expression="" field="architecture"/>
    <default applyOnUpdate="0" expression="" field="localisation"/>
    <default applyOnUpdate="0" expression="" field="naturerevetement"/>
    <default applyOnUpdate="0" expression="" field="mobilierurbain"/>
    <default applyOnUpdate="0" expression="" field="anneeplantation"/>
    <default applyOnUpdate="0" expression="" field="commune"/>
    <default applyOnUpdate="0" expression="" field="codeinsee"/>
    <default applyOnUpdate="0" expression="" field="nomvoie"/>
    <default applyOnUpdate="0" expression="" field="codefuv"/>
    <default applyOnUpdate="0" expression="" field="identifiant"/>
    <default applyOnUpdate="0" expression="" field="numero"/>
    <default applyOnUpdate="0" expression="" field="codegenre"/>
    <default applyOnUpdate="0" expression="" field="gid"/>
    <default applyOnUpdate="0" expression="" field="surfacecadre_m2"/>
  </defaults>
  <constraints>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="essencefrancais" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="circonference_cm" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="hauteurtotale_m" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="hauteurfut_m" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="diametrecouronne_m" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="rayoncouronne_m" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="dateplantation" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="genre" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="espece" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="variete" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="essence" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="architecture" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="localisation" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="naturerevetement" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="mobilierurbain" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="anneeplantation" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="commune" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="codeinsee" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="nomvoie" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="codefuv" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="identifiant" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="numero" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="codegenre" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="gid" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="surfacecadre_m2" exp_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="" field="essencefrancais" desc=""/>
    <constraint exp="" field="circonference_cm" desc=""/>
    <constraint exp="" field="hauteurtotale_m" desc=""/>
    <constraint exp="" field="hauteurfut_m" desc=""/>
    <constraint exp="" field="diametrecouronne_m" desc=""/>
    <constraint exp="" field="rayoncouronne_m" desc=""/>
    <constraint exp="" field="dateplantation" desc=""/>
    <constraint exp="" field="genre" desc=""/>
    <constraint exp="" field="espece" desc=""/>
    <constraint exp="" field="variete" desc=""/>
    <constraint exp="" field="essence" desc=""/>
    <constraint exp="" field="architecture" desc=""/>
    <constraint exp="" field="localisation" desc=""/>
    <constraint exp="" field="naturerevetement" desc=""/>
    <constraint exp="" field="mobilierurbain" desc=""/>
    <constraint exp="" field="anneeplantation" desc=""/>
    <constraint exp="" field="commune" desc=""/>
    <constraint exp="" field="codeinsee" desc=""/>
    <constraint exp="" field="nomvoie" desc=""/>
    <constraint exp="" field="codefuv" desc=""/>
    <constraint exp="" field="identifiant" desc=""/>
    <constraint exp="" field="numero" desc=""/>
    <constraint exp="" field="codegenre" desc=""/>
    <constraint exp="" field="gid" desc=""/>
    <constraint exp="" field="surfacecadre_m2" desc=""/>
  </constraintExpressions>
  <expressionfields/>
  <attributeactions>
    <defaultAction key="Canvas" value="{00000000-0000-0000-0000-000000000000}"/>
  </attributeactions>
  <attributetableconfig actionWidgetStyle="dropDown" sortOrder="0" sortExpression="">
    <columns>
      <column type="field" width="-1" name="essencefrancais" hidden="0"/>
      <column type="field" width="-1" name="circonference_cm" hidden="0"/>
      <column type="field" width="-1" name="hauteurtotale_m" hidden="0"/>
      <column type="field" width="-1" name="hauteurfut_m" hidden="0"/>
      <column type="field" width="-1" name="diametrecouronne_m" hidden="0"/>
      <column type="field" width="-1" name="rayoncouronne_m" hidden="0"/>
      <column type="field" width="-1" name="dateplantation" hidden="0"/>
      <column type="field" width="-1" name="genre" hidden="0"/>
      <column type="field" width="-1" name="espece" hidden="0"/>
      <column type="field" width="-1" name="variete" hidden="0"/>
      <column type="field" width="-1" name="essence" hidden="0"/>
      <column type="field" width="-1" name="architecture" hidden="0"/>
      <column type="field" width="-1" name="localisation" hidden="0"/>
      <column type="field" width="-1" name="naturerevetement" hidden="0"/>
      <column type="field" width="-1" name="mobilierurbain" hidden="0"/>
      <column type="field" width="-1" name="anneeplantation" hidden="0"/>
      <column type="field" width="-1" name="commune" hidden="0"/>
      <column type="field" width="-1" name="codeinsee" hidden="0"/>
      <column type="field" width="-1" name="nomvoie" hidden="0"/>
      <column type="field" width="-1" name="codefuv" hidden="0"/>
      <column type="field" width="-1" name="identifiant" hidden="0"/>
      <column type="field" width="-1" name="numero" hidden="0"/>
      <column type="field" width="-1" name="codegenre" hidden="0"/>
      <column type="field" width="-1" name="gid" hidden="0"/>
      <column type="field" width="-1" name="surfacecadre_m2" hidden="0"/>
      <column type="actions" width="-1" hidden="1"/>
    </columns>
  </attributetableconfig>
  <conditionalstyles>
    <rowstyles/>
    <fieldstyles/>
  </conditionalstyles>
  <storedexpressions/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
Les formulaires QGIS peuvent avoir une fonction Python qui sera appelée à l'ouverture du formulaire.

Utilisez cette fonction pour ajouter plus de fonctionnalités à vos formulaires.

Entrez le nom de la fonction dans le champ "Fonction d'initialisation Python".
Voici un exemple à suivre:
"""
from qgis.PyQt.QtWidgets import QWidget

def my_form_open(dialog, layer, feature):
	geom = feature.geometry()
	control = dialog.findChild(QWidget, "MyLineEdit")

]]></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>generatedlayout</editorlayout>
  <editable>
    <field name="anneeplantation" editable="1"/>
    <field name="architecture" editable="1"/>
    <field name="circonference_cm" editable="1"/>
    <field name="codefuv" editable="1"/>
    <field name="codegenre" editable="1"/>
    <field name="codeinsee" editable="1"/>
    <field name="commune" editable="1"/>
    <field name="dateplantation" editable="1"/>
    <field name="diametrecouronne_m" editable="1"/>
    <field name="espece" editable="1"/>
    <field name="essence" editable="1"/>
    <field name="essencefrancais" editable="1"/>
    <field name="genre" editable="1"/>
    <field name="gid" editable="1"/>
    <field name="hauteurfut_m" editable="1"/>
    <field name="hauteurtotale_m" editable="1"/>
    <field name="identifiant" editable="1"/>
    <field name="localisation" editable="1"/>
    <field name="mobilierurbain" editable="1"/>
    <field name="naturerevetement" editable="1"/>
    <field name="nomvoie" editable="1"/>
    <field name="numero" editable="1"/>
    <field name="rayoncouronne_m" editable="1"/>
    <field name="surfacecadre_m2" editable="1"/>
    <field name="variete" editable="1"/>
  </editable>
  <labelOnTop>
    <field name="anneeplantation" labelOnTop="0"/>
    <field name="architecture" labelOnTop="0"/>
    <field name="circonference_cm" labelOnTop="0"/>
    <field name="codefuv" labelOnTop="0"/>
    <field name="codegenre" labelOnTop="0"/>
    <field name="codeinsee" labelOnTop="0"/>
    <field name="commune" labelOnTop="0"/>
    <field name="dateplantation" labelOnTop="0"/>
    <field name="diametrecouronne_m" labelOnTop="0"/>
    <field name="espece" labelOnTop="0"/>
    <field name="essence" labelOnTop="0"/>
    <field name="essencefrancais" labelOnTop="0"/>
    <field name="genre" labelOnTop="0"/>
    <field name="gid" labelOnTop="0"/>
    <field name="hauteurfut_m" labelOnTop="0"/>
    <field name="hauteurtotale_m" labelOnTop="0"/>
    <field name="identifiant" labelOnTop="0"/>
    <field name="localisation" labelOnTop="0"/>
    <field name="mobilierurbain" labelOnTop="0"/>
    <field name="naturerevetement" labelOnTop="0"/>
    <field name="nomvoie" labelOnTop="0"/>
    <field name="numero" labelOnTop="0"/>
    <field name="rayoncouronne_m" labelOnTop="0"/>
    <field name="surfacecadre_m2" labelOnTop="0"/>
    <field name="variete" labelOnTop="0"/>
  </labelOnTop>
  <dataDefinedFieldProperties/>
  <widgets/>
  <previewExpression>"nomvoie"</previewExpression>
  <mapTip></mapTip>
  <layerGeometryType>0</layerGeometryType>
</qgis>
