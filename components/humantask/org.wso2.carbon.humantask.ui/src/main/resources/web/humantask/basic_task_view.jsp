<%@ page import="org.apache.axiom.om.OMElement" %>
<%@ page import="org.apache.axis2.context.ConfigurationContext" %>
<%@ page import="org.apache.axis2.databinding.types.URI" %>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page
        import="org.apache.commons.logging.LogFactory" %>
<%@ page
        import="org.apache.http.HttpStatus" %>
<%@ page import="org.wso2.carbon.CarbonConstants" %>
<%@ page import="org.wso2.carbon.humantask.stub.ui.task.client.api.types.TTaskAbstract" %>
<%@ page
        import="org.wso2.carbon.humantask.ui.clients.HumanTaskClientAPIServiceClient" %>
<%@ page
        import="org.wso2.carbon.ui.CarbonUIMessage" %>
<%@ page import="org.wso2.carbon.ui.CarbonUIUtil" %>
<%@ page import="org.wso2.carbon.utils.ServerConstants" %>
<%@ page
        import="org.wso2.carbon.humantask.stub.ui.task.client.api.types.TTaskAuthorisationParams" %>
<%@ page import="org.wso2.carbon.humantask.stub.ui.task.client.api.types.TStatus" %>
<%@ page import="org.wso2.carbon.humantask.ui.util.HumanTaskUIUtil" %>
<%@ page import="org.wso2.carbon.businessprocesses.common.utils.CharacterEncoder" %>
<!--
~ Copyright (c) WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
~
~ WSO2 Inc. licenses this file to you under the Apache License,
~ Version 2.0 (the "License"); you may not use this file except
~ in compliance with the License.
~ You may obtain a copy of the License at
~
~ http://www.apache.org/licenses/LICENSE-2.0
~
~ Unless required by applicable law or agreed to in writing,
~ software distributed under the License is distributed on an
~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
~ KIND, either express or implied. See the License for the
~ specific language governing permissions and limitations
~ under the License.
-->
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://wso2.org/projects/carbon/taglibs/carbontags.jar" prefix="carbon" %>

<jsp:include page="../resources/resources-i18n-ajaxprocessor.jsp"/>
    <%
        response.setHeader("Cache-Control",
                           "no-store, max-age=0, no-cache, must-revalidate");
        // Set IE extended HTTP/1.1 no-cache headers.
        response.addHeader("Cache-Control", "post-check=0, pre-check=0");
        // Set standard HTTP/1.0 no-cache header.
        response.setHeader("Pragma", "no-cache");

        String backendServerURL = CarbonUIUtil.getServerURL(config.getServletContext(), session);
        ConfigurationContext configContext =
                (ConfigurationContext) config.getServletContext().getAttribute(CarbonConstants.CONFIGURATION_CONTEXT);
        String cookie = (String) session.getAttribute(ServerConstants.ADMIN_SERVICE_COOKIE);

        String taskId =  CharacterEncoder.getSafeText(request.getParameter("taskId"));
        String taskClient =  CharacterEncoder.getSafeText(request.getParameter("taskClient"));
        TTaskAuthorisationParams authParams = null;

        HumanTaskClientAPIServiceClient taskAPIClient;

        TTaskAbstract task = null;

        try {
            taskAPIClient = new HumanTaskClientAPIServiceClient(cookie, backendServerURL, configContext);
            URI taskIdURI = new URI(taskId);
            task = taskAPIClient.loadTask(taskIdURI);
            OMElement input = taskAPIClient.loadTaskInput(taskIdURI);
            if ("COMPLETED".equals(task.getStatus().toString()) || task.getHasOutput() ) {
                OMElement output = taskAPIClient.loadTaskOutput(taskIdURI);
                if (output != null) {
                    request.setAttribute("taskOutput", output);
                }
            }

            authParams = taskAPIClient.getTaskParams(taskIdURI);
            request.setAttribute("LoadedTask", task);
            request.setAttribute("taskClient", "carbon");
            request.setAttribute("TaskAuthorisationParams", authParams);
            request.setAttribute("taskInput", input);
            request.setAttribute("taskId", taskId);

        } catch (Exception e) {
            response.setStatus(HttpStatus.SC_INTERNAL_SERVER_ERROR);
            String msg = e.getMessage();
            CarbonUIMessage.sendCarbonUIMessage(msg, CarbonUIMessage.ERROR, request);
    %>
    <jsp:include page="../admin/error.jsp"/>
    <%
            return;
        }

    %>

<fmt:bundle basename="org.wso2.carbon.humantask.ui.i18n.Resources">
<carbon:breadcrumb
        label="humantask.task.info"
        resourceBundle="org.wso2.carbon.humantask.ui.i18n.Resources"
        topPage="false"
        request="<%=request%>"/>
         <jsp:include page="../dialog/display_messages.jsp"/>
    <div id="middle">
        <div id="package-list-main">
            <%
                String taskDisplayId = HumanTaskUIUtil.getTaskDisplayId(task);
            %>
            <h2><%=taskDisplayId%>
            </h2>

            <div id="workArea">
                <jsp:include page="task_view_temp.jsp"/>
            </div>
        </div>
    </div>

</fmt:bundle>