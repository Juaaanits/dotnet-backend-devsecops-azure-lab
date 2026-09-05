using System.ComponentModel.DataAnnotations;

namespace sakenny.Application.DTO
{
    public class AddServiceDTO
    {
        [Required(ErrorMessage = "Service name is required.")]
        [StringLength(100, MinimumLength = 3, ErrorMessage = "Name must be between 3 and 100 characters.")]
        public string Name { get; set; }

        [Required(ErrorMessage = "Service icon is required.")]
        [StringLength(200, MinimumLength = 2, ErrorMessage = "Icon must be between 2 and 200 characters.")]
        public string Icon { get; set; }

    }
}
