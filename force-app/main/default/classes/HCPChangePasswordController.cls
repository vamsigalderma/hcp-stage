public without sharing class HCPChangePasswordController {
	public HCPChangePasswordController() {
		String email = ApexPages.currentPage().getParameters().get('email');
		String sitePrefix = Site.getPathPrefix();
		String templateName = String.isNotBlank(sitePrefix) && sitePrefix.contains('th') ? 'HCPChangePassword_Thailand' : 'HCPChangePassword';
		result = Site.forgotPassword(email, templateName);
		if(!result) {
			throw new CalloutException();
		}
	}
	public Boolean result {get; set;}
}