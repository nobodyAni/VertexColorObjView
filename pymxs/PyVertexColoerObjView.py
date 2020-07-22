import MaxPlus
import pymxs
from PySide2 import QtWidgets, QtCore, QtGui

RT = pymxs.runtime
RT.clearlistener()
class VertexColorView(QtWidgets.QDialog):
    m_EditableMesh_str = u"Editable_mesh"
    m_editablePoly_str = u"Editable_Poly"
    def __init__(self, parent=MaxPlus.GetQMaxMainWindow()):
        super(VertexColorView, self).__init__(parent)
        self.coler_list =[]
        self.obj_name = u""
        self.obj_type = u"ploy"
        self.setWindowTitle(u"버텍스 칼라 뷰")
        self.initUI()
    def initUI(self):
        #UI객체
        self.color_table_widget = QtWidgets.QTableWidget(1,2)
        self.color_table_widget.setHorizontalHeaderLabels([u"뷰전환",u"버택스칼라 색상",u"버택스넘버"])
        self.select_button = QtWidgets.QPushButton(u"선택")
        self.select_button.clicked.connect(self.select_object)
        self.select_name_label = QtWidgets.QLabel(u'선택된 오브젝트 이름')
        #레이아웃
        self.main_layout = QtWidgets.QVBoxLayout()
        self.head_layout = QtWidgets.QHBoxLayout()
        self.head_layout.addWidget(self.select_button)
        self.head_layout.addWidget(self.select_name_label)
        self.main_layout.addLayout(self.head_layout)
        self.main_layout.addWidget(self.color_table_widget)
        self.setLayout(self.main_layout)
    def update_color_table(self, ):
        pass

    def select_object(self):
        pass
        #GetObjVertsColor 선택한 오브젝트의 버텍스 칼라 얻어오기
        #칼라정보, 버택스 리스트
        
    def update_UI(self):
        pass
        table_item = QtWidgets.QTableWidgetItem(u'Hide')
        color_table_widget.setItem(0,0,table_item)

    def testData(self):
        pass
try:
    vertex_color_view.close()
except:
    pass
vertex_color_view = VertexColorView()
vertex_color_view.show()