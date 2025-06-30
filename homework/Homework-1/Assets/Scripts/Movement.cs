using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Movement : MonoBehaviour
{
    float horizontal;

    [SerializeField]
    float speed;
    // Start is called before the first frame update
    void Start()
    {
        horizontal = 0;
        speed = 3;
    }

    // Update is called once per frame
    void Update()
    {
        horizontal = Input.GetAxis("Horizontal");
    }
    void FixedUpdate(){
        Rigidbody2D rb = GetComponent<Rigidbody2D>();
        rb.linearVelocity = new Vector2(horizontal * speed,rb.linearVelocity.y);
    }
}
