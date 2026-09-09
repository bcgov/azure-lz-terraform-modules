variable "deny_azure_ai_services_parameters" {
  type = object({
    deny_ai_foundry            = string
    deny_ai_hubs               = string
    deny_azure_openai          = string
    deny_ai_search             = string
    deny_bot_services          = string
    deny_computer_vision       = string
    deny_custom_vision         = string
    deny_content_safety        = string
    deny_document_intelligence = string
    deny_face_api              = string
    deny_health_insights       = string
    deny_machine_learning      = string
    deny_immersive_reader      = string
    deny_language_service      = string
    deny_speech_service        = string
    deny_translator            = string
  })
  description = "Parameter values for the Deny-Azure-AI-Services initiative assignment."
}
