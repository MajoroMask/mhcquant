process OPENMS_IDCONFLICTRESOLVER {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::openms=2.8.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/openms:2.9.1--h135471a_1' :
        'biocontainers/openms:2.9.1--h135471a_1' }"

    input:
        tuple val(meta), path(consensus)

    output:
        tuple val(meta), path("*.consensusXML"), emit: consensusxml
        path "versions.yml"                    , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def prefix           = task.ext.prefix ?: "${meta.id}_resolved"

        """
        IDConflictResolver -in $consensus \\
            -out ${prefix}.consensusXML \\
            -threads $task.cpus

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            openms: \$(echo \$(FileInfo --help 2>&1) | sed 's/^.*Version: //; s/-.*\$//' | sed 's/ -*//; s/ .*\$//')
        END_VERSIONS
        """
}
