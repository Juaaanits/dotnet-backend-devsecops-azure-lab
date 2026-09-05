using System.ComponentModel.DataAnnotations;

namespace sakenny.Application.DTO
{
    public class LoginDTO
    {

        [Required(ErrorMessage = "Username is required.")]
        public string Email { get; set; }
        public string Password { get; set; }
        public bool RememberMe { get; set; }
    }
}
