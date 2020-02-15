macroScript VertexColorMeshView

category:"_AniSeoHyun"
tooltip:"버텍스칼라 모델뷰"
icon:#("",0)
(
-- 오브젝트에 사용된 버텍스 칼라 색갈별로 리스트 생성
-- 해당 리스트를 클릭하면 해당 버택스 선택
-- 버택스를 페이스로 변환후 하이드/언하이드

rollout VertexColorView_rollout "모델 등급 보기" width:250 height:80
(
    -- 변수
    local m_targetHide_color = color 255 0 0  --숨김처리하는 버텍스칼라
    local m_skin_nodeArray = #()

    -- 함수
    fn SetHideFace_bool obj_node:undefined vert_intArray:#() = (
        face_bitArray = meshop.getFacesUsingVert obj_node vert_intArray
        meshop.setHiddenFaces obj_node face_bitArray
        update obj_node
        true
    )
    fn UpdateSkinMeshArray_fn = (
        m_skin_nodeArray = #()
        for obj_node in (objects as array) do (
            if obj_node.modifiers[#Skin] != undefined do (
                append m_skin_nodeArray obj_node
            )
        )
    )
    fn CheckIsNodeArray_fn target_nodeArray:#() =(
        isfalseNode_bool = false
        for obj_node in target_nodeArray do (
            if not isValidNode obj_node do (
                isfalseNode_bool = true
            )
        )
        if isfalseNode_bool do (
            UpdateSkinMeshArray_fn()
        )
    )
    fn RunLowMesh_fn target_nodeArray:(objects as array) = (
        -- Mesh인지 poly인지 체크
        for obj_node in target_nodeArray do (
            --print obj_node.name
            modPanel.setCurrentObject obj_node.baseObject
            if (isKindOf obj_node Editable_mesh) do (
                verts_BitArray = meshop.getVertsByColor obj_node m_targetHide_color 0 0 0
                SetHideFace_bool obj_node:obj_node vert_intArray:verts_BitArray
                update obj_node
            )
            if (isKindOf obj_node Editable_Poly) do (
                vet_bitArray = polyop.getVertsByColor obj_node m_targetHide_color 0 0 0
                face_bitArray = polyop.getFacesUsingVert obj_node vet_bitArray
                polyop.setHiddenFaces obj_node face_bitArray
                update obj_node
            )
        )
    )

    button ui_lowMeshOn "하이드"
    button ui_highMeshOn "언하이드"
    on ui_lowMeshOn pressed do (
        CheckIsNodeArray_fn target_nodeArray:m_skin_nodeArray
        sel_nodeArray = (selection as array)
        clearSelection()
        RunLowMesh_fn target_nodeArray:m_skin_nodeArray
        redrawViews() 
        clearSelection()
        select sel_nodeArray
    )
    on ui_highMeshOn pressed do (
        CheckIsNodeArray_fn target_nodeArray:m_skin_nodeArray
        sel_nodeArray = (selection as array)
        clearSelection()
        for obj_node in m_skin_nodeArray do (
            modPanel.setCurrentObject obj_node.baseObject
            if (isKindOf obj_node Editable_mesh) do (
                SetHideFace_bool obj_node:obj_node
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
        UpdateSkinMeshArray_fn()
    )
)
if VertexColorView_rollout != undefined do (
    DestroyDialog  VertexColorView_rollout
)
createDialog VertexColorView_rollout  style:#(#style_toolwindow, #style_sysmenu, #style_resizing)
)