process MSCONVERT {
    tag "$meta.id"
    label 'process_low'


    if (params.enable_conda && meta.ext == 'd') {
            { exit 1, "Converting bruker tdf file format to mzml is only supported using docker. Aborting." }
    }


    container "chambm/pwiz-skyline-i-agree-to-the-vendor-licenses"

    input:
        tuple val(meta), path(brukerfile)

    output:
        tuple val(meta), path("*.mzML"), emit: mzml
        path "versions.yml"            , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def prefix           = task.ext.prefix ?: "${brukerfile.simpleName}"


        """
        tar -xzf $brukerfile -C .
        
        wine msconvert \
            -v \
            --mzML \
            --inten64 \
            --zlib \
            --combineIonMobilitySpectra \
            --filter "scanSumming precursorTol=0.05 scanTimeTol=10 ionMobilityTol=0.01" \
            ${prefix}.d

        
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            msconvert: \$(wine msconvert --help 2>&1 | grep release | cut -f3 -d ' ')
        END_VERSIONS
        """
}
