<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="user.UserDAO" %>
<%@ page import="evaluation.EvaluationDTO" %>
<%@ page import="evaluation.EvaluationDAO" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.net.URLEncoder" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
	<title>왓플릭스</title>
	<link rel="icon" type="image/x-icon" href="assets/img/favicon.ico" />
	<!-- 부트스트랩 CSS 추가 -->
	<link rel="stylesheet" href="./css/bootstrap.min.css">
	<!-- Custom CSS 추가 -->
	<link rel="stylesheet" href="./css/custom.css">
</head>
<body>
	<%
		request.setCharacterEncoding("UTF-8");
		String genre = "전체";
		String searchType = "최신순";
		String search = "";
		int pageNumber = 0;
		if (request.getParameter("genre") != null) {
			genre = request.getParameter("genre");
		}
		if (request.getParameter("searchType") != null) {
			searchType = request.getParameter("searchType");
		}
		if (request.getParameter("search") != null) {
			search = request.getParameter("search");
		}
		if (request.getParameter("pageNumber") != null) {
			try {
				pageNumber = Integer.parseInt(request.getParameter("pageNumber"));
			} catch (Exception e) {
				System.out.println("검색 페이지 번호 오류");
			}
			
		}
		String userID = null;
		if (session.getAttribute("userID") != null) {
			userID = (String)session.getAttribute("userID");
		}
		if (userID == null) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인을 해주세요.');");
			script.println("location.href = 'userLogin.jsp'");
			script.println("</script>");
			script.close();
			return;
		}
		boolean emailChecked = new UserDAO().getUserEmailChecked(userID);
		if (emailChecked == false) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("location.href = 'emailSendConfirm.jsp'");
			script.println("</script>");
			script.close();
			return;
		}
	%>
	<jsp:include page="menu.jsp">
		<jsp:param value="<%=userID %>" name="userID"/>
	</jsp:include>
	<section class="container">
		<form method="GET" action="./main.jsp" class="form-inline mt-3">
			<select name="genre" class="form-control mx-1 mt-2">
				<option value="전체">전체</option>
				<option value="한국" <% if(genre.contentEquals("한국")) out.println("selected"); %>>한국</option>
				<option value="미국" <% if(genre.contentEquals("미국")) out.println("selected"); %>>미국</option>
				<option value="외국" <% if(genre.contentEquals("외국")) out.println("selected"); %>>외국</option>
			</select>
			<select name="searchType" class="form-control mx-1 mt-2">
				<option value="최신순">최신순</option>
				<option value="추천순" <% if(genre.contentEquals("추천순")) out.println("selected"); %>>추천순</option>
			</select>
			<input type="text" name="search" class="form-control mx-1 mt-2" placeholder="내용을 입력하세요">
			<button type="submit" class="btn btn-primary mx-1 mt-2">검색</button>
			<a class="btn btn-primary mx-1 mt-2" data-toggle="modal" href="#registerModal">등록하기</a>
			<a class="btn btn-danger mx-1 mt-2" data-toggle="modal" href="#reportModal">신고</a>
		</form>
		<%
			ArrayList<EvaluationDTO> evaluationList = new ArrayList<EvaluationDTO>();
			evaluationList = new EvaluationDAO().getList(genre, searchType, search, pageNumber);
			if (evaluationList != null) {
				for (int i = 0; i < evaluationList.size(); i++) {
					if (i == 5)	break;
					EvaluationDTO evaluation = evaluationList.get(i);
		%>
		<div class="card bg-dark mt-3">
			<div class="card-header bg-dark">
				<div class="row">
					<div class="col-8 text-left"><%= evaluation.getMovieTitle() %>&nbsp;<small><%= evaluation.getDirectorName() %></small></div> 
					<div class="col-4 text-right">
						종합<span style="color: red;"> <%=evaluation.getTotalScore() %></span>
					</div>
				</div>
			</div>
			<div class="card-body">
				<h5 class="card-title">
					<%= evaluation.getEvaluationTitle() %>&nbsp;
				</h5>
				<p class="card-text"><%= evaluation.getEvaluationContent() %></p>
				<div class="row">
					<div class="col-9 text-left">
						스토리<span style="color: red;"> <%= evaluation.getStoryScore() %></span>
						영상<span style="color: red;"> <%= evaluation.getVideoScore() %></span>
						인물<span style="color: red;"> <%= evaluation.getCharacterScore() %></span>
						<span style="color: green;">(추천: <%= evaluation.getLikeCount() %>)</span>
					</div>
					<div class="col-3 text-right">
						<a onclick="return confirm('추천하시겠습니까?')" href="./likeAction.jsp?evaluationID=<%=evaluation.getEvaluationID()%>">추천</a>
						<a onclick="return confirm('삭제하시겠습니까?')" href="./deleteAction.jsp?evaluationID=<%=evaluation.getEvaluationID()%>">삭제</a>
					</div>
				</div>
			</div>
		</div>
		<%
				}
			}
		%>
	</section>
	<ul class="pagination justify-content-center mt-3">
		<li class="page-item">
		<%
			if (pageNumber <= 0) {
		%>
				<a class="page-link disabled">이전</a>
		<%
			} else {
		%>
				<a class="page-link" href="./main.jsp?genre=<%= URLEncoder.encode(genre, "UTF-8") %>&searchType=
				<%= URLEncoder.encode(searchType, "UTF-8") %>&search=<%= URLEncoder.encode(search, "UTF-8") %>&pageNumber=
				<%=pageNumber -1 %>">이전</a>
		<%
			}
		%>
		</li>
		<li class="page-item">
		<%
			if (evaluationList.size() < 6) {
		%>
				<a class="page-link disabled">다음</a>
		<%
			} else {
		%>
				<a class="page-link" href="./main.jsp?genre=<%= URLEncoder.encode(genre, "UTF-8") %>&searchType=
				<%= URLEncoder.encode(searchType, "UTF-8") %>&search=<%= URLEncoder.encode(search, "UTF-8") %>&pageNumber=
				<%=pageNumber + 1 %>">다음</a>
		<%
			}
		%>
		
		</li>
		
	</ul>
	<div class="modal fade" id="registerModal" tabindex="-1" role="dialog" aria-labelledby="modal" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="modal">나의 영화를 공유해주세요!</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">&times;</span>
					</button>
				</div>
				<div class="modal-body">
					<form action="./evaluationRegisterAction.jsp" method="POST">
						<div class="form-row">
							<div class="form-group col-sm-6">
								<label>영화 제목</label>
								<input type="text" name="movieTitle" class="form-control" maxlength="20">
							</div>
							<div class="form-group col-sm-3">
								<label>감독</label>
								<input type="text" name="directorName" class="form-control" maxlength="20">
							</div>
							<div class="form-group col-sm-3">
								<label>장르</label>
								<select name="genre" class="form-control">
									<option value="한국" selected>한국</option>
									<option value="미국">미국</option>
									<option value="외국">외국</option>
								</select>
							</div>
						</div>
						<div class="form-group">
							<label>제목</label>
							<input type="text" name="evaluationTitle" class="form-control" maxlength="30">
						</div>
						<div class="form-group">
							<label>내용</label>
							<textarea name="evaluationContent" class="form-control" maxlength="2048" style="height:180px;"></textarea>
						</div>
						<div class="form-row">
							<div class="form-group col-sm-3">
								<label>종합</label>
								<select name="totalScore" class="form-control">
									<option value="10" selected>10</option>
									<option value="9">9</option>
									<option value="8">8</option>
									<option value="7">7</option>
									<option value="6">6</option>
									<option value="5">5</option>
									<option value="4">4</option>
									<option value="3">3</option>
									<option value="2">2</option>
									<option value="1">1</option>
									<option value="0">0</option>				
								</select>
							</div>
							<div class="form-group col-sm-3">
								<label>스토리</label>
								<select name="storyScore" class="form-control">
									<option value="10" selected>10</option>
									<option value="9">9</option>
									<option value="8">8</option>
									<option value="7">7</option>
									<option value="6">6</option>
									<option value="5">5</option>
									<option value="4">4</option>
									<option value="3">3</option>
									<option value="2">2</option>
									<option value="1">1</option>
									<option value="0">0</option>					
								</select>
							</div>
							<div class="form-group col-sm-3">
								<label>영상</label>
								<select name="videoScore" class="form-control">
									<option value="10" selected>10</option>
									<option value="9">9</option>
									<option value="8">8</option>
									<option value="7">7</option>
									<option value="6">6</option>
									<option value="5">5</option>
									<option value="4">4</option>
									<option value="3">3</option>
									<option value="2">2</option>
									<option value="1">1</option>
									<option value="0">0</option>						
								</select>
							</div>
							<div class="form-group col-sm-3">
								<label>인물</label>
								<select name="characterScore" class="form-control">
									<option value="10" selected>10</option>
									<option value="9">9</option>
									<option value="8">8</option>
									<option value="7">7</option>
									<option value="6">6</option>
									<option value="5">5</option>
									<option value="4">4</option>
									<option value="3">3</option>
									<option value="2">2</option>
									<option value="1">1</option>
									<option value="0">0</option>					
								</select>
							</div>
						</div>
						<div class="modal-footer">
							<button type="button" class="btn btn-secondary" data-dismiss="modal">취소</button>
							<button type="submit" class="btn btn-primary">등록하기</button>
						</div>
					</form>
				</div>
				
			</div>
		</div>
	</div>
	<div class="modal fade" id="reportModal" tabindex="-1" role="dialog" aria-labelledby="modal" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="modal">신고하기</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">&times;</span>
					</button>
				</div>
				<div class="modal-body">
					<form action="./reportAction.jsp" method="POST">
						<div class="form-group">
							<label>신고 제목</label>
							<input type="text" name="reportTitle" class="form-control" maxlength="30">
						</div>
						<div class="form-group">
							<label>신고 내용</label>
							<textarea name="reportContent" class="form-control" maxlength="2048" style="height:180px;"></textarea>
						</div>
						<div class="modal-footer">
							<button type="button" class="btn btn-secondary" data-dismiss="modal">취소</button>
							<button type="submit" class="btn btn-danger">신고하기</button>
						</div>
					</form>
				</div>
				
			</div>
		</div>
	</div>
	<%@ include file="footer.jsp" %>
	<!-- jQuery 추가 -->
	<script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>
	<!-- popper 추가 -->
	<script src="./js/popper.js"></script>
	<!-- 부트스트랩 js 추가 -->
	<script src="./js/bootstrap.min.js"></script>
</body>
</html>