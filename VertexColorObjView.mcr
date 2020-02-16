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
    local m_target_nodeArray = #()

    -- 함수
    fn SetHideFace_bool obj_node:undefined vert_intArray:#() = (
        face_bitArray = meshop.getFacesUsingVert obj_node vert_intArray
        meshop.setHiddenFaces obj_node face_bitArray
        update obj_node
        true
    )
    fn UpdateHideMeshArray_fn = (
        m_target_nodeArray = #()
        for obj_node in (selection as array) do (
            if (isKindOf obj_node Editable_mesh) or (isKindOf obj_node Editable_Poly) do (
                append m_target_nodeArray obj_node
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
            UpdateHideMeshArray_fn()
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
    colorpicker ui_hideColor "숨김처리할 색:" color:[255,0,0] modal:true
    button ui_selectMesh "적용 할 것 선택"
    button ui_hideMeshOn "하이드" across:2
    button ui_hideMeshOff "언하이드"

    on ui_hideColor changed pick_color do (
        m_targetHide_color = pick_color
    )
    on ui_selectMesh pressed do (
        UpdateHideMeshArray_fn()
    )
    on ui_hideMeshOn pressed do (
        CheckIsNodeArray_fn target_nodeArray:m_target_nodeArray
        sel_nodeArray = (selection as array)
        clearSelection()
        RunLowMesh_fn target_nodeArray:m_target_nodeArray
        redrawViews() 
        clearSelection()
        select sel_nodeArray
    )
    on ui_hideMeshOff pressed do (
        CheckIsNodeArray_fn target_nodeArray:m_target_nodeArray
        sel_nodeArray = (selection as array)
        clearSelection()
        for obj_node in m_target_nodeArray do (
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
        UpdateHideMeshArray_fn()
    )
)
if VertexColorView_rollout != undefined do (
    DestroyDialog  VertexColorView_rollout
)
createDialog VertexColorView_rollout  style:#(#style_toolwindow, #style_sysmenu, #style_resizing)
)