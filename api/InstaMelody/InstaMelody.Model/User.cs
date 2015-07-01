﻿using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.ComponentModel.DataAnnotations;

namespace InstaMelody.Model
{
    public class User
    {
        private string _email;
        private string _displayName;

        public Guid Id { get; set; }

        public int? UserImageId { get; set; }

        [StringLength(320, ErrorMessage = "Email address cannot exceed 320 characters.")]
        public string EmailAddress 
        { 
            get
            {
                return _email;
            }
            set
            {
                var email = value;
                if (!string.IsNullOrWhiteSpace(email) && !Utilities.IsValidEmail(email))
                {
                    throw new FormatException("Email address is not properly formatted");
                }
                _email = email;
            }
        }

        [Required(ErrorMessage = "Display name is required.")]
        [StringLength(32, ErrorMessage = "Display name cannot exceed 32 characters")]
        [MinLength(6, ErrorMessage = "Display name must be at least 6 characters")]
        public string DisplayName 
        { 
            get
            {
                return _displayName;
            }
            set
            {
                if (!string.IsNullOrWhiteSpace(value))
                {
                    _displayName = Utilities.RemoveSpecialCharacters(value);
                }
            }
        }

        [StringLength(64, ErrorMessage = "First name cannot exceed 64 characters")]
        public string FirstName { get; set; }

        [StringLength(64, ErrorMessage = "Last name cannot exceed 64 characters")]
        public string LastName { get; set; }

        [StringLength(28, ErrorMessage = "Phone number cannot exceed 28 characters")]
        public string PhoneNumber { get; set; }

        [StringLength(64, ErrorMessage = "Hash salt cannot exceed 64 characters")]
        public string HashSalt { get; set; }

        [Required]
        [StringLength(255, ErrorMessage = "Password cannot exceed 255 characters")]
        public string Password { get; set; }

        [StringLength(128, ErrorMessage = "TwitterUsername cannot exceed 128 characters")]
        public string TwitterUsername { get; set; }

        [StringLength(128, ErrorMessage = "TwitterUserId cannot exceed 128 characters")]
        public string TwitterUserId { get; set; }

        [StringLength(255, ErrorMessage = "TwitterToken cannot exceed 255 characters")]
        public string TwitterToken { get; set; }

        [StringLength(255, ErrorMessage = "TwitterSecret cannot exceed 255 characters")]
        public string TwitterSecret { get; set; }

        [StringLength(128, ErrorMessage = "FacebookUserId cannot exceed 128 characters")]
        public string FacebookUserId { get; set; }

        [StringLength(255, ErrorMessage = "FacebookToken cannot exceed 255 characters")]
        public string FacebookToken { get; set; }

        public DateTime? LastLoginSuccess { get; set; }

        public DateTime? LastLoginFailure { get; set; }

        public int NumberLoginFailures { get; set; }

        public bool IsLocked { get; set; }

        public DateTime DateCreated { get; set; }

        public DateTime DateModified { get; set; }

        public bool IsDeleted { get; set; }

        #region Relationship Properties

        public Image Image { get; set; }

        public IList<UserMessage> Messages { get; set; }

        public IList<User> Friends { get; set; }

        #endregion Relationship Properties

        /// <summary>
        /// Parses from data reader.
        /// </summary>
        /// <param name="dataReader">The data reader.</param>
        /// <returns></returns>
        public User ParseFromDataReader(SqlDataReader dataReader)
        {
            this.Id = (Guid)dataReader["Id"];
            if (dataReader["UserImageId"] is DBNull)
            {
                this.UserImageId = null;
            }
            else
            {
                this.UserImageId = Convert.ToInt32(dataReader["UserImageId"]);
            }
            this.EmailAddress = Convert.ToString(dataReader["EmailAddress"]);
            this.DisplayName = Convert.ToString(dataReader["DisplayName"]);
            this.FirstName = Convert.ToString(dataReader["FirstName"]);
            this.LastName = Convert.ToString(dataReader["LastName"]);
            this.PhoneNumber = Convert.ToString(dataReader["PhoneNumber"]);
            this.HashSalt = Convert.ToString(dataReader["HashSalt"]);
            this.Password = Convert.ToString(dataReader["Password"]);
            this.TwitterUsername = Convert.ToString(dataReader["TwitterUsername"]);
            this.TwitterUserId = Convert.ToString(dataReader["TwitterUserId"]);
            this.TwitterToken = Convert.ToString(dataReader["TwitterToken"]);
            this.TwitterSecret = Convert.ToString(dataReader["TwitterSecret"]);
            this.FacebookUserId = Convert.ToString(dataReader["FacebookUserId"]);
            this.FacebookToken = Convert.ToString(dataReader["FacebookToken"]);
            this.LastLoginSuccess = dataReader["LastLoginSuccess"] is DBNull
                ? new DateTime()
                : Convert.ToDateTime(dataReader["LastLoginSuccess"]);
            this.LastLoginFailure = dataReader["LastLoginFailure"] is DBNull
                ? new DateTime()
                : Convert.ToDateTime(dataReader["LastLoginFailure"]);
            this.NumberLoginFailures = Convert.ToInt32(dataReader["NumberLoginFailures"]);
            this.IsLocked = Convert.ToBoolean(dataReader["IsLocked"]);
            this.DateCreated = Convert.ToDateTime(dataReader["DateCreated"]);
            this.DateModified = Convert.ToDateTime(dataReader["DateModified"]);
            this.IsDeleted = Convert.ToBoolean(dataReader["IsDeleted"]);

            return this;
        }

        /// <summary>
        /// Strips the sensitive information.
        /// </summary>
        /// <returns></returns>
        public User StripSensitiveInfo()
        {
            this.HashSalt = string.Empty;
            this.Password = string.Empty;

            return this;
        }

        /// <summary>
        /// Clones this instance.
        /// </summary>
        /// <returns></returns>
        public User Clone()
        {
            var result = (User)this.MemberwiseClone();
            return result;
        }
    }
}
