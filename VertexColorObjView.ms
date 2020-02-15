-- 버택스칼라 기준으로 스킨 오브젝트를 보여주고주는 기능
-- 오브젝트에 사용된 버텍스 칼라 색갈별로 리스트 생성
-- 해당 리스트를 클릭하면 해당 버택스 선택
-- 버택스를 페이스로 변환후 하이드/언하이드

rollout VertexColorView_rollout "모델 등급 보기" width:250 height:150
(
    -- 변수
    local m_colorList_colorArray = #()
    local m_targetHide_color = color 255 0 0  --숨김처리하는 버텍스칼라
    local m_skin_nodeArray = #()

    -- 함수
    fn GetVertexColor_ColorArray obj_mesh:undefined =  (
        num = getNumCPVVerts obj_mesh
        m_colorList_colorArray = #()
        for i = 1 to num do (
            appendIfUnique m_colorList_colorArray (getVertColor obj_mesh i) 
        )
        m_colorList_colorArray
    )
    fn GetVertexByColor_intArray obj_mesh:undefined target_color:(color 255 255 255) = (
        num = getNumCPVVerts obj_mesh
        vert_intArray = #()
        for i = 1 to num do (
            if (getVertColor obj_mesh i)  == target_color do append vert_intArray i
        )
        vert_intArray
    )
    fn SetHideFace_bool obj_mesh:undefined vert_intArray:#() = (
        face_bitArray = meshop.getFacesUsingVert obj_mesh vert_intArray
        meshop.setHiddenFaces obj_mesh face_bitArray
        update obj_mesh
        true
    )
    fn SetUnHideAllFace_bool obj_mesh:undefined = (
        meshop.setHiddenFaces obj_mesh #{}
        true
    )
    fn RunLowMesh_fn target_nodeArray:(objects as array) = (
        -- Mesh인지 poly인지 체크
        for obj_node in target_nodeArray do (
            --print obj_node.name
            modPanel.setCurrentObject obj_node.baseObject
            if (isKindOf obj_node Editable_mesh) do (
                obj_mesh = obj_node
                int_Array = GetVertexByColor_intArray obj_mesh:obj_mesh target_color:m_targetHide_color
                SetHideFace_bool obj_mesh:obj_mesh vert_intArray:int_Array
                update obj_mesh
            )
            if (isKindOf obj_node Editable_Poly) do (
                vet_bitArray = polyop.getVertsByColor obj_node m_targetHide_color 0 0 0
                face_bitArray = polyop.getFacesUsingVert obj_node vet_bitArray
                polyop.setHiddenFaces obj_node face_bitArray
                update obj_node
            )
        )
    )

    button ui_lowMeshOn "저렙용"
    button ui_highMeshOn "고렙용"
    on ui_lowMeshOn pressed do (
        sel_nodeArray = (selection as array)
        clearSelection()
        RunLowMesh_fn target_nodeArray:m_skin_nodeArray
        redrawViews() 
        clearSelection()
        select sel_nodeArray
    )
    on ui_highMeshOn pressed do (
        sel_nodeArray = (selection as array)
        clearSelection()
        for obj_node in m_skin_nodeArray do (
            modPanel.setCurrentObject obj_node.baseObject
            if (isKindOf obj_node Editable_mesh) do (
                SetHideFace_bool obj_mesh:obj_node
            )
            if (isKindOf obj_node Editable_Poly) do (
                polyop.unHideAllFaces obj_node 
            )
        )
        redrawViews()
        clearSelection()
        select sel_nodeArray
    )
    on VertexColorView_rollout open do (
        m_skin_nodeArray = #()
        for obj_node in (objects as array) do (
            if obj_node.modifiers[#Skin] != undefined do (
                append m_skin_nodeArray obj_node
            )
        )
    )
)
if VertexColorView_rollout != undefined do (
    DestroyDialog  VertexColorView_rollout
)
createDialog VertexColorView_rollout  style:#(#style_toolwindow, #style_sysmenu, #style_resizing)
--addRollout  VertexColorView_rollout VertexColorView_rolloutFloater