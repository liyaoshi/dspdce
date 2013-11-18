/*!
 *  ======== UNIVERSAL========
 *  UNIVERSAL codec specification
 *
 *  This file specifies information necessary to integrate with the Codec
 *  Engine.
 *
 *  By inheriting ti.sdo.ce.universal.IUNIVERSAL, UNIVERSAL declares that it "is
 *  a" universal algorithm.  This allows the codec engine to automatically
 *  supply simple stubs and skeletons for transparent execution of DSP
 *  codecs by the GPP.
 *
 *  In addition to declaring the type of the UNIVERSAL algorithm, we
 *  declare the external symbol required by xDAIS that identifies the
 *  algorithms implementation functions.
 */
metaonly module UNIVERSAL inherits ti.sdo.ce.universal.IUNIVERSAL
{
    readonly config ti.sdo.codecs.universal.UNIVERSAL.Module alg =
        ti.sdo.codecs.universal.UNIVERSAL;
    
    override readonly config String ialgFxns = "UNIVERSALCOPY_TI_IUNIVERSALCOPY";

}
