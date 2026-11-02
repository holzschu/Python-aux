#include <stdio.h>
#include <string.h>
#include <libxml/parser.h>
#include <libxslt/transform.h>
#include <libxslt/xsltutils.h>
#include <libexslt/exslt.h>

int main(void) {
    const char input[] = "<values><n>2</n><n>5</n></values>";
    const char stylesheet[] =
        "<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform' "
        "xmlns:math='http://exslt.org/math'>"
        "<xsl:output method='text'/><xsl:template match='/'>"
        "<xsl:value-of select='math:max(/values/n)'/>"
        "</xsl:template></xsl:stylesheet>";
    exsltRegisterAll();
    xmlDocPtr document = xmlReadMemory(input, sizeof(input) - 1, "input.xml", NULL, 0);
    xmlDocPtr style_document = xmlReadMemory(stylesheet, sizeof(stylesheet) - 1, "style.xsl", NULL, 0);
    if (!document || !style_document) return 1;
    xsltStylesheetPtr style = xsltParseStylesheetDoc(style_document);
    if (!style) return 1;
    xmlDocPtr result = xsltApplyStylesheet(style, document, NULL);
    if (!result) return 1;
    xmlChar *text = NULL;
    int length = 0;
    int status = xsltSaveResultToString(&text, &length, result, style);
    int failed = status < 0 || length != 1 || !text || text[0] != '5';
    if (failed) fprintf(stderr, "XSLT/EXSLT result differs from expected 5\n");
    else puts("XSLT and EXSLT transformation passed");
    xmlFree(text);
    xmlFreeDoc(result);
    xsltFreeStylesheet(style);
    xmlFreeDoc(document);
    xsltCleanupGlobals();
    xmlCleanupParser();
    return failed;
}
