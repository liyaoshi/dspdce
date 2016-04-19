/*
 *  ======== package.xs ========
 *
 */

/*
 *  ======== getLibs ========
 */
function getLibs(prog)
{
    var lib = null;
  
    if (prog.build.target.isa == "64T") {        
        if ( this.UNIVERSAL.watermark == false ) {
                lib = "lib/universal_copy.ae64T";
        }
        else {
                lib = null;
        }
        print("    will link with " + this.$name + ":" + lib);
    }
    return (lib);
}

/*
 *  ======== getSects ========
 */
function getSects()
{
    var template = null;

    if (Program.build.target.isa == "64T") {
        template = "ti/sdo/codecs/universal/link.xdt";
    }

    return (template);
}
