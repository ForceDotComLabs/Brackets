/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
public with sharing class BracketsImportExportUtilities {
    public static final String NOT_UPDATES_FOUND = 'No Updates found.';
    public static final String JSON_PARAMENTER = 'json';
    public static final String MISSING_TOURNAMENT = 'The tournament was deleted.';
    public static final String SUCCESSFUL_TOURNAMENT_IMPORT = 'Import successful.';
    public static final String FAIL_TOURNAMENT_IMPORT = 'Import failed.';
    public static final String PARENT_TOURNAMENT_SITE_ERRORS = 'Tournament source site reports errors: ';
    public static final String ERROR_TAG = 'error';

    /**
     * Method used for sanatizing input for XML document
     * @param out
     * @param tag
     * @param content
     */
    public static void writeElement(
        Xmlstreamwriter out,
        String tag,
        String content
    ) {
        out.writeStartElement(null, tag, null);
        out.writeCharacters(EncodingUtil.urlEncode(content, 'UTF-8'));
        out.writeEndElement();
    }

    /**
     * Method for decoding strings from XML document
     * @param reader
     * @return String
     */
    public static String getDecodedString(Xmlstreamreader reader) {
        return EncodingUtil.urlDecode(reader.getText(), 'UTF-8').trim();
    }
}
