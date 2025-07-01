using UnityEngine;

public class Dvijenie : MonoBehaviour
{
    float horizontal;
    bool jumping = false;
    bool grounded = false;

    [SerializeField]
    float speed;

    [SerializeField]
    float upthrust;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        horizontal = 0;
    }

    // Update is called once per frame
    void Update()
    {
        if (!jumping)
        {
            jumping = grounded && Input.GetButtonDown("Jump");
        }
    }

    void FixedUpdate()
    {
        // strani4no dvijenie
        horizontal = Input.GetAxis("Horizontal");
        Rigidbody2D rb = GetComponent<Rigidbody2D>();

        rb.linearVelocity = new Vector2(horizontal * speed, rb.linearVelocity.y);

        // ska4ane
        if (jumping)
        {
            rb.AddForce(new Vector2(0, upthrust), ForceMode2D.Impulse);
            jumping = false;
        }
    }

    void OnCollisionEnter2D(Collision2D collider2D)
    {
        Vector2 boxPos = transform.position;
        boxPos.y -= 1.1f;
        RaycastHit2D[] raycastHits2D = Physics2D.BoxCastAll(boxPos, new Vector2(1, 1), 0, new Vector2(0, 0));

        grounded = false;

        foreach (var item in raycastHits2D)
        {
            if (item.collider.gameObject.name != "igra4")
            {
                grounded = true;
            }
        }
    }

    void OnCollisionExit2D(Collision2D collider2D)
    {
        grounded = false;
    }

    public bool MidAir()
    {
        return !grounded;
    }
}
