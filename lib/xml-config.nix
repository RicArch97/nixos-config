# functions to generate XML configs from Nix
{
  inputs,
  lib,
  pkgs,
  ...
}: let
  stylesheetCommonHeader = ''
    <?xml version="1.0"?>
    <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='1.0'>
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
  '';

  stylesheetRootTag = rootTag: ''
    <xsl:template match='/'>
      <xsl:comment> Generated config by Nix. </xsl:comment>
      <${rootTag}>
        <xsl:apply-templates/>
      </${rootTag}>
    </xsl:template>
  '';

  stylesheetNestedTags = ''
    <!-- Template for elements with attributes -->
    <xsl:template match="attr[attrs]">
      <xsl:variable name="elementName" select="@name"/>
      <xsl:element name="{$elementName}">
        <xsl:apply-templates select="attrs" />
      </xsl:element>
    </xsl:template>

    <!-- Template for elements with _attrs -->
    <xsl:template match="attr[attrs[attr[@name='_attrs']]]">
      <xsl:variable name="elementName" select="@name"/>
      <xsl:element name="{$elementName}">
        <xsl:apply-templates select="attrs/attr[@name='_attrs']/attrs/attr" />
        <xsl:apply-templates select="attrs/attr[not(@name='_attrs')]" />
      </xsl:element>
    </xsl:template>

    <!-- Template for lists of attributes -->
    <xsl:template match="attr[list[attrs]]">
      <xsl:variable name="elementName" select="@name"/>
      <xsl:for-each select="list/attrs">
        <xsl:element name="{$elementName}">
          <xsl:apply-templates select="attr[@name='_attrs']/attrs/attr" />
          <xsl:apply-templates select="attr[not(@name='_attrs')]" />
        </xsl:element>
      </xsl:for-each>
    </xsl:template>

    <!-- Template for elements with no nested attributes or lists -->
    <xsl:template match="attr[not(attrs|list)]">
      <xsl:variable name="elementName" select="@name"/>
      <xsl:element name="{$elementName}">
        <xsl:value-of select="*/@value" />
      </xsl:element>
    </xsl:template>

    <!-- Template for handling _attrs as element attributes -->
    <xsl:template match="attr[@name='_attrs']/attrs/attr">
      <xsl:attribute name="{@name}">
        <xsl:value-of select="string/@value"/>
      </xsl:attribute>
    </xsl:template>
  '';

  stylesheetCommonFooter = "</xsl:stylesheet>";

  attrsetToXml = attrs: name: stylesheet:
    pkgs.runCommand name {
      nativeBuildInputs = [pkgs.buildPackages.libxslt.bin];
      xml = builtins.toXML attrs;
      passAsFile = ["xml"];
    } ''
      xsltproc ${stylesheet} - < "$xmlPath" > "$out"
    '';
in {
  convertAttrsetToXml = attrs: name: rootTag: let
    stylesheet = builtins.toFile "stylesheet.xsl" ''
      ${stylesheetCommonHeader}
      ${stylesheetRootTag rootTag}
      ${stylesheetNestedTags}
      ${stylesheetCommonFooter}
    '';
  in
    attrsetToXml attrs name stylesheet;
}
