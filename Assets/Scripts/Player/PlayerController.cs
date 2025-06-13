using UnityEngine;

namespace Player
{
    public class PlayerController : MonoBehaviour
    {
        public float moveSpeed = 5f;
        public float jumpForce = 5f;

        private Rigidbody rb;
        private Animator animator;
        private bool isGrounded;

        void Start()
        {
            rb = GetComponent<Rigidbody>();
            animator = GetComponent<Animator>();
        }

        void Update()
        {
            float move = Input.GetAxis("Horizontal");

            Vector3 movement = new Vector3(move, 0f, 0f);
            transform.Translate(movement * moveSpeed * Time.deltaTime);

            if (move != 0)
            {
                animator.SetBool("isWalking", true);
            }
            else
            {
                animator.SetBool("isWalking", false);
            }

            if (Input.GetKeyDown(KeyCode.Space) && isGrounded)
            {
                rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
                animator.SetTrigger("Jump");
            }

            if (Input.GetKeyDown(KeyCode.F))
            {
                animator.SetTrigger("Attack");
            }
        }

        void OnCollisionEnter(Collision collision)
        {
            if (collision.gameObject.CompareTag("Ground"))
            {
                isGrounded = true;
            }
        }

        void OnCollisionExit(Collision collision)
        {
            if (collision.gameObject.CompareTag("Ground"))
            {
                isGrounded = false;
            }
        }
    }
}
