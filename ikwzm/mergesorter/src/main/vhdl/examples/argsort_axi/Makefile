
ENTITY_FILES = argsort_axi_interface.vhd \
               argsort_reader.vhd        \
               argsort_writer.vhd        \
               argsort_axi_reader.vhd    \
               argsort_axi_writer.vhd    \
               argsort_axi.vhd           \
               argsort_kernel.vhd        \
               ${ENDLIST}

argsort_axi_components.vhd : ${ENTITY_FILES}
	../../../../../PipeWork/tools/MakeComponentPackage.rb --verbose \
            --brief   'ArgSorter Component Library Description Package' \
            --version 1.4.1 \
            --author  'Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>' \
            --library Merge_Sorter \
            --package ArgSort_AXI_Components \
            --output  argsort_axi_components.vhd \
            ${ENTITY_FILES}

clean:
	-rm argsort_axi_components.vhd
