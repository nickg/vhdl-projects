
ENTITY_FILES = merge_reader.vhd          \
               merge_writer.vhd          \
               merge_axi_reader.vhd      \
               merge_axi_writer.vhd      \
               interface_controller.vhd  \
               ${ENDLIST}

merge_sorter_interface_components.vhd : ${ENTITY_FILES}
	../../../../PipeWork/tools/MakeComponentPackage.rb --verbose \
            --brief   'Merge Sorter Interface Component Library Description Package' \
            --version 1.3.0 \
            --author  'Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>' \
            --library Merge_Sorter \
            --package Interface_Components \
            --output  interface_components.vhd \
            ${ENTITY_FILES}

clean:
	-rm interface_components.vhd
