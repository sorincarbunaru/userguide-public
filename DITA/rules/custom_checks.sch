<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process" queryBinding="xslt2"
    xmlns="http://www.w3.org/1999/xhtml">
    <sch:ns uri="http://www.oxygenxml.com/ai/function" prefix="ai"/>
  
    <!-- Missing table cells validation -->
    <sch:pattern>
        <sch:rule context="table">
            <sch:let name="minColumsNo" value="min(.//row/count(entry))"/>
            <sch:let name="reqColumsNo" value="max(.//row/count(entry))"/>
            <sch:assert test="$minColumsNo >= $reqColumsNo" id="tableCellsID">Some table cells are missing. The
                number of cells for each row must be <sch:value-of select="$reqColumsNo"/>. Add the necesary cells.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>
