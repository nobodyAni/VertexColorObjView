import MaxPlus
import pymxs
from PySide2 import QtWidgets, QtCore, QtGui

rt = pymxs.runtime
rt.clearlistener()
class VertexColorObj():
    index = None
    node = None
    type = None
    colorlist = []
class VertexColorView(QtWidgets.QDialog):
    targetNodes = []
    obj_fn = rt.meshop
    fnPoly = rt.Editable_Poly
    fnMesh = rt.Editable_Mesh
    fnPolyMesh = rt.PolyMeshObject
    # m_EditableMesh_str = u"Editable_mesh"
    # m_editablePoly_str = u"Editable_Poly"
    def __init__(self, parent=MaxPlus.GetQMaxMainWindow()):
        super(VertexColorView, self).__init__(parent)
        self.targetNodes = []
        self.coler_list =[]
        self.obj_name = u""
        self.obj_type = u"ploy"
        self.setWindowTitle(u"버텍스 칼라 뷰")
        rt.disableSceneRedraw()
        self.progress()
        self.initUI()
        rt.enableSceneRedraw()
        
    def initUI(self):
        # print('initUI in')
        #UI객체
        self.text_qlabel =  QtWidgets.QLabel(u"준비중... ")
        self.color_tree_widget = QtWidgets.QTreeWidget()
        self.color_tree_widget.setExpandsOnDoubleClick(False)
        self.color_tree_widget.setHeaderLabels([u"숨김리스트",u"색상","Model_Index", "Color_Index"])
        head_item = self.color_tree_widget.headerItem()
        head_item.setSizeHint(0, QtCore.QSize(500, 25))
        head_view = self.color_tree_widget.header()
        head_view.resizeSection(0, 180)
        head_view.resizeSection(1, 90)
        self.color_tree_widget.setFocusPolicy(QtCore.Qt.NoFocus)
        self.color_tree_widget.setSelectionMode(QtWidgets.QAbstractItemView.NoSelection)
        self.update_UI()
        self.color_tree_widget.itemChanged.connect(self.runVertsByColor)
        self.unHideAll_qbutton =  QtWidgets.QPushButton(u"UnHideAll", default = False, autoDefault = False)
        self.unHideAll_qbutton.clicked.connect(self.run_unHideAll)
        #레이아웃
        self.head_layout = QtWidgets.QHBoxLayout()
        self.head_layout.addWidget(self.text_qlabel)
        self.bottom_layout = QtWidgets.QHBoxLayout()
        self.bottom_layout.addWidget(self.unHideAll_qbutton)
        self.main_layout = QtWidgets.QVBoxLayout()
        self.main_layout.addLayout(self.head_layout)
        self.main_layout.addWidget(self.color_tree_widget)
        self.main_layout.addLayout(self.bottom_layout)
        self.setLayout(self.main_layout)
    def progress(self):
        isPoly = self.fnPoly
        isMesh = self.fnMesh
        isPolyMesh = self.fnPolyMesh
        index = 0
        for node in (rt.objects):
            # print(node.name)
            new_color_set = VertexColorObj()
            color_list = []
            obj_type = None
            if rt.isKindOf(node, isPoly):
                obj_type = isPoly
            if rt.isKindOf(node, isMesh):
                obj_type = isMesh
            if rt.isKindOf(node, isPolyMesh):
                obj_type = isPolyMesh
            if obj_type == None:
                continue
            cvp = rt.getNumCPVVerts(node.mesh)
            if  cvp > 0 and obj_type != None:
                # print('is v obj')
                new_color_set.node = node
                if rt.isKindOf(node, isMesh):
                    for i in range(1, cvp):
                        c = rt.getVertColor(node, i)
                        color_list.append(c)
                else:
                    node_mesh = node.mesh
                    for i in range(1, cvp):
                        c = rt.getVertColor(node_mesh, i)
                        color_list.append(c)
                new_color_set.type = obj_type
                new_color_set.colorlist = set(color_list)
                new_color_set.index = index
                self.targetNodes.append(new_color_set)
                index += 1
        #GetObjVertsColor 선택한 오브젝트의 버텍스 칼라 얻어오기
        #칼라정보, 버택스 리스트
    def update_UI(self):
        for color_set in self.targetNodes:
            item = QtWidgets.QTreeWidgetItem(self.color_tree_widget)
            item.setExpanded(True)
            # print(color_set.node)
            obj_name = color_set.node.name
            item.setText(0, obj_name)
            # for color_value in color_set.colorlist:
            color_list = list(color_set.colorlist)
            for i in range(0, len(color_list)):
                sub_item = QtWidgets.QTreeWidgetItem(item)
                sub_item.setCheckState(0, QtCore.Qt.Unchecked )
                sub_item.setTextColor(0,QtGui.QColor(255, 255, 255))
                sub_item.setText(0, str(color_list[i]))
                # sub_item.setBackground(1, color_qbrush)
                map = QtGui.QPixmap(15,15)
                map.fill(QtGui.QColor(color_list[i].r, color_list[i].g, color_list[i].b))
                icon = QtGui.QIcon(map)
                sub_item.setIcon(1,icon)
                sub_item.setText(2,str(color_set.index))
                sub_item.setText(3,str(i))
        if len(self.targetNodes) == 0:
            text = u'버택스 칼라 오브젝트가 없습니다.'
        else:
            text = u'숨기고 싶은 색상을 체크표시하세요.'
        self.text_qlabel.setText(text)
    def update_color_table(self, ):
        pass
    def runVertsByColor(self, item, column):
        self.text_qlabel.setText(u'실행중')
        rt.disableSceneRedraw()
        index_str = item.text(column+2)
        color_set = self.targetNodes[int(index_str)]
        node = color_set.node
        color_list = list(color_set.colorlist)
        color_index = int(item.text(column+3))
        color_value = color_list[color_index]
        fnPolyop = rt.polyop
        verts_BitArray = None
        face_bitArray = None
        hide_bitArray = None
        new_bitArray = None
        # rt.modPanel.setCurrentObject(node.baseObject)
        if item.checkState(column) == QtCore.Qt.Checked:
            if color_set.type == self.fnMesh:
                verts_BitArray = rt.meshop.getVertsByColor(node, color_value, 0,0,0 )
                face_bitArray = rt.meshop.getFacesUsingVert(node, verts_BitArray)
                hide_bitArray = rt.meshop.getHiddenFaces(node)
                rt.meshop.setHiddenFaces(node,face_bitArray + hide_bitArray)
            else:
                verts_BitArray = fnPolyop.getVertsByColor(node, color_value, 0,0,0 )
                face_bitArray = fnPolyop.getFacesUsingVert(node, verts_BitArray)
                fnPolyop.setHiddenFaces(node, face_bitArray)
        if item.checkState(column) == QtCore.Qt.Unchecked:
            if color_set.type == self.fnMesh:
                verts_BitArray = rt.meshop.getVertsByColor(node, color_value, 0,0,0 )
                face_bitArray = rt.meshop.getFacesUsingVert(node, verts_BitArray)
                hide_bitArray = rt.meshop.getHiddenFaces(node)
                rt.meshop.setHiddenFaces(node, hide_bitArray - face_bitArray)
            else:
                if color_set.type == self.fnPolyMesh:
                    node = node.baseObject
                hide_bitArray = fnPolyop.getHiddenFaces(node)
                rt.redrawViews()
                # print(hide_bitArray)
                verts_BitArray = fnPolyop.getVertsByColor(node, color_value, 0,0,0 )
                face_bitArray = fnPolyop.getFacesUsingVert(node, verts_BitArray)
                new_bitArray = hide_bitArray - face_bitArray
                fnPolyop.unHideAllFaces(node)
                # print(new_bitArray)
                fnPolyop.setHiddenFaces(node, new_bitArray)
        rt.update(color_set.node)
        rt.enableSceneRedraw()
        rt.redrawViews()
        self.text_qlabel.setText(u'완료')
    def run_unHideAll(self):
        rt.disableSceneRedraw()
        for color_set in self.targetNodes:
            node = color_set.node
            if color_set.type == self.fnMesh:
                rt.meshop.setHiddenFaces(node,rt.bitArray())
            else:
                rt.polyop.unHideAllFaces(node)
        rt.enableSceneRedraw()
        rt.redrawViews()
        self.close()
        VertexColorView().show()

VertexColorView().show()