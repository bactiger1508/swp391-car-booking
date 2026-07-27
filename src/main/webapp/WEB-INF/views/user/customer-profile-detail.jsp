<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Customer Profile Detail"/>
</jsp:include>

<div class="page-content">
    <div class="card">
        <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
            <h2>Customer Profile Detail</h2>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/user/customer-profiles?status=${param.searchStatus}&keyword=${param.searchKeyword}">
                Quay lại
            </a>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <table class="table table-bordered">
            <tr><th width="220">ID hồ sơ</th><td>${profile.profileId}</td></tr>
            <tr><th>Họ và tên</th><td>${customerName}</td></tr>
            <tr><th>Địa chỉ email</th><td>${customerEmail}</td></tr>
            <tr><th>ID Người dùng</th><td>${profile.userId}</td></tr>
            <tr><th>Ngày sinh</th><td>${profile.dateOfBirth}</td></tr>
            <tr><th>Địa chỉ thường trú</th><td>${profile.address}</td></tr>
            <tr><th>Số CCCD / Hộ chiếu</th><td>${profile.idCardNumber}</td></tr>
            <tr><th>Số Giấy phép lái xe</th><td>${profile.driverLicenseNumber}</td></tr>
            <tr>
                <th>Ngày hết hạn Giấy phép lái xe</th>
                <td>
                    <c:choose>
                        <c:when test="${not empty profile.driverLicenseExpiry}">
                            ${profile.driverLicenseExpiry}
                        </c:when>
                        <c:otherwise>Không thời hạn</c:otherwise>
                    </c:choose>
                </td>
            </tr>
            <tr>
                <th>Ảnh CCCD mặt trước</th>
                <td>
                    <c:choose>
                        <c:when test="${not empty profile.idCardImageFront}">
                            <img src="${pageContext.request.contextPath}/${profile.idCardImageFront}" width="450" style="border-radius:10px; border:1px solid #ccc;">
                        </c:when>
                        <c:otherwise><span style="color:red">Không có ảnh</span></c:otherwise>
                    </c:choose>
                </td>
            </tr>
            <tr>
                <th>Ảnh CCCD mặt sau</th>
                <td>
                    <c:choose>
                        <c:when test="${not empty profile.idCardImageBack}">
                            <img src="${pageContext.request.contextPath}/${profile.idCardImageBack}" width="450" style="border-radius:10px; border:1px solid #ccc;">
                        </c:when>
                        <c:otherwise><span style="color:red">Không có ảnh</span></c:otherwise>
                    </c:choose>
                </td>
            </tr>
            <tr>
                <th>Ảnh Giấy phép lái xe</th>
                <td>
                    <c:choose>
                        <c:when test="${not empty profile.driverLicenseImage}">
                            <img src="${pageContext.request.contextPath}/${profile.driverLicenseImage}" width="450" style="border-radius:10px; border:1px solid #ccc;">
                        </c:when>
                        <c:otherwise><span style="color:red">Không có ảnh</span></c:otherwise>
                    </c:choose>
                </td>
            </tr>
            <tr>
                <th>Trạng thái</th>
                <td>
                    <c:choose>
                        <c:when test="${profile.verificationStatus == 'PENDING'}"><span class="badge badge-warning">Pending</span></c:when>
                        <c:when test="${profile.verificationStatus == 'VERIFIED'}"><span class="badge badge-success">Verified</span></c:when>
                        <c:otherwise><span class="badge badge-danger">Rejected</span></c:otherwise>
                    </c:choose>
                </td>
            </tr>
        </table>
        <br>

        <c:if test="${profile.verificationStatus=='PENDING'}">
            <div style="display:flex; flex-direction: column; gap:15px; background: #f9f9f9; padding: 20px; border-radius: 8px;">
                <h3>Xử lý yêu cầu hồ sơ</h3>
                <div style="display: flex; gap: 15px;">
                    <form id="verifyForm"
                          method="post"
                          action="${pageContext.request.contextPath}/user/customer-profiles">

                        <input type="hidden" name="action" value="verify">
                        <input type="hidden" name="profileId" value="${profile.profileId}">

                        <button
                            type="button"
                            class="btn btn-success"
                            onclick="openConfirmModal(
                                            'Xác minh hồ sơ',
                                            'Bạn có chắc chắn muốn xác minh hồ sơ này?',
                                            this.form,
                                            'success'
                                            )">

                            Đồng ý

                        </button>

                    </form>

                    <form id="rejectForm"
                          method="post"
                          action="${pageContext.request.contextPath}/user/customer-profiles">

                        <input type="hidden" name="action" value="reject">
                        <input type="hidden" name="profileId" value="${profile.profileId}">

                        <button
                            type="button"
                            class="btn btn-danger"
                            onclick="openConfirmModal(
                                            'Từ chối hồ sơ',
                                            'Bạn có chắc chắn muốn từ chối hồ sơ này?',
                                            this.form,
                                            'danger'
                                            )">

                            Từ chối

                        </button>

                    </form>
                </div>
            </div>
        </c:if>
    </div>
</div>
<div id="confirmModal" class="modal-overlay">
    <div class="modal-box">
        <div id="modalIcon" class="modal-icon">
            <span class="material-symbols-outlined">
                warning
            </span>
        </div>
        <h3 id="modalTitle"></h3>
        <p id="modalMessage"></p>
        <div class="modal-actions">
            <button
                type="button"
                class="btn btn-outline"
                onclick="closeConfirmModal()">
                Hủy
            </button>
            <button
                id="confirmBtn"
                type="button"
                class="btn">
                Xác nhận
            </button>
        </div>
    </div>
</div>

<style>
.modal-overlay{
    display:none;
    position:fixed;
    inset:0;
    background:rgba(0,0,0,.45);
    justify-content:center;
    align-items:center;
    z-index:9999;
}
.modal-box{
    width:430px;
    background:white;
    border-radius:16px;
    padding:28px;
    text-align:center;
    box-shadow:0 10px 40px rgba(0,0,0,.25);
    animation:popup .25s;
}
@keyframes popup{
from{
transform:scale(.8);
opacity:0;
}
to{
transform:scale(1);
opacity:1;
}
}
.modal-icon{
width:70px;
height:70px;
margin:auto;
border-radius:50%;
display:flex;
align-items:center;
justify-content:center;
margin-bottom:18px;
}
.modal-icon.success{
background:#dcfce7;
color:#16a34a;
}
.modal-icon.danger{
background:#fee2e2;
color:#dc2626;
}
.modal-actions{
margin-top:25px;
display:flex;
justify-content:center;
gap:15px;
}
</style>
            
<script>
let selectedForm = null;
function openConfirmModal(title,message,form,type){
    selectedForm = form;
    document.getElementById("modalTitle").innerText = title;
    document.getElementById("modalMessage").innerText = message;
    const icon=document.getElementById("modalIcon");
    const btn=document.getElementById("confirmBtn");
    icon.className="modal-icon "+type;
    if(type==="success"){
        icon.innerHTML="<span class='material-symbols-outlined'>verified</span>";
        btn.className="btn btn-success";
        btn.innerText="Đồng ý";
    }

    else{
        icon.innerHTML="<span class='material-symbols-outlined'>cancel</span>";
        btn.className="btn btn-danger";
        btn.innerText="Từ chối";
    }
    document.getElementById("confirmModal").style.display="flex";
}
function closeConfirmModal(){
    document.getElementById("confirmModal").style.display="none";
}
document.getElementById("confirmBtn").onclick=function(){
    selectedForm.submit();
};
window.onclick=function(e){
    if(e.target.id==="confirmModal"){
        closeConfirmModal();
    }
}
</script>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>